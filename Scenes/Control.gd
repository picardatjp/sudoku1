extends Control

#node pointers
onready var board = $ColorRect/board
onready var rect_highlight = $ColorRect/board/rect_highlight
onready var indicator_rect_column = $ColorRect/board/indicator_rect_column
onready var indicator_rect_row = $ColorRect/board/indicator_rect_row
onready var markup_button = $ColorRect/Markup_button
onready var rin_button = $ColorRect/RIN_button
onready var grid = $ColorRect/board/Grid
onready var puzzle_label = $ColorRect/puzzle_label
onready var diff_label = $ColorRect/diff_label
onready var check_status_label = $ColorRect/check_status_label
onready var completed_label = $ColorRect/completed_label

#variables
var puzzles_path = Globals.puzzles_path
var user_data_path = Globals.user_data_path
var puzzle_solutions_path = Globals.puzzle_solutions_path
var last_puzzle_path = Globals.last_puzzle_path
var puzzle_difficulty = Globals.puzzle_difficulty
var puzzle_num = Globals.puzzle_num
var puzzles = {}
var user_puzzles = {}
var puzzle_solutions = {}
var label_array = []
var cell_size = 52
var highlight_coord = Vector2.ZERO
var highlight_active = false
var coord = Vector2.ZERO
var markup_status = false
var completed_puzzles = {}

func _ready():
	#initially turn rect_highlight off(the blue square)
	rect_highlight.visible = false
	#set the colors of the markup and edit buttons
	markup_button["custom_styles/normal"].bg_color = Color("#930606")
	markup_button["custom_styles/pressed"].bg_color = Color("#7f0606")
	markup_button["custom_styles/hover"].bg_color = Color("#890606")
	rin_button["custom_styles/normal"].bg_color = Color("#930606")
	rin_button["custom_styles/pressed"].bg_color = Color("#7f0606")
	rin_button["custom_styles/hover"].bg_color = Color("#890606")
	#this is for setting the difficulty and puzzle number at the top of the screen
	if Globals.puzzle_difficulty == 0:
		diff_label.set_text("Easy")
	elif Globals.puzzle_difficulty == 1:
		diff_label.set_text("Medium")
	elif Globals.puzzle_difficulty == 2:
		diff_label.set_text("Hard")
	puzzle_label.set_text(str(Globals.puzzle_num))
	
	#open and populate solutions !!!!
	var file = File.new()
	if file.file_exists(puzzle_solutions_path):
		var error = file.open(puzzle_solutions_path,File.READ)
		#if it opened fine
		if error == OK:
			#put json data into puzzle solutions dictionary
			var text = file.get_as_text()
			puzzle_solutions = parse_json(text)
		file.close()
	
	#initialize label_array
	label_array.resize(81)
	#retireve puzzle data
	get_puzzle()
	#create labels
	label_setup()
	#set labels to their values from the json files
	set_label_puzzle_data()
#	print("mouse: " + str(get_global_mouse_position()))
	check_status_label.set_text("")
	

func _input(event):
	#check for mouse movement
	if event is InputEventMouseMotion:
		#if is mouse movement is inside the sudoku board
		if event.global_position[0] > board.get_global_position().x and event.global_position[0] < board.get_global_position().x + cell_size*9 and event.global_position[1] > board.get_global_position().y and event.global_position[1] < board.get_global_position().y + cell_size*9:
			#make the gray bars visible
			indicator_rect_column.visible = true
			indicator_rect_row.visible = true
			#pos = (mouse position - start of the sudoku board) / cell_size. This says which square of the sudoku board the mouse is in
			var pos = Vector2(int((event.global_position[0]-board.get_global_position().x)/cell_size),int((event.global_position[1]-board.get_global_position().y)/cell_size))
			#if the cell the mouse is in hasn't changed
			if pos != coord:
				#set the new coord for the indicator lines (gray bars) to follow
				coord = pos
				move_indicator_lines()
#				move_rect()
#				print(coord)
		#if the mouse is not within the boundaries of the sudoku board
		else:
			#hide the gray bars
			indicator_rect_column.visible = false
			indicator_rect_row.visible = false
	#if mouse button pressed
	if event is InputEventMouseButton:
		#if pressed on sudoku board
		if event.global_position[0] > board.get_global_position().x and event.global_position[0] < board.get_global_position().x + cell_size*9 and event.global_position[1] > board.get_global_position().y and event.global_position[1] < board.get_global_position().y + cell_size*9:
			#set and move highlight rectangle(blue square)
			rect_highlight.visible = highlight_active
			highlight_coord = coord
			move_rect()
	#if a number or backspace or delete si pressed and current selection isn't from the original puzzle, and markup is off(big number mode)
	if event is InputEventKey and puzzles[str(puzzle_difficulty)][str(puzzle_num)][1][highlight_coord.y*9 + highlight_coord.x] == "." and not markup_status:
		if event.scancode == KEY_1 and highlight_active:
			set_label_big("1")
		elif event.scancode == KEY_2 and highlight_active:
			set_label_big("2")
		elif event.scancode == KEY_3 and highlight_active:
			set_label_big("3")
		elif event.scancode == KEY_4 and highlight_active:
			set_label_big("4")
		elif event.scancode == KEY_5 and highlight_active:
			set_label_big("5")
		elif event.scancode == KEY_6 and highlight_active:
			set_label_big("6")
		elif event.scancode == KEY_7 and highlight_active:
			set_label_big("7")
		elif event.scancode == KEY_8 and highlight_active:
			set_label_big("8")
		elif event.scancode == KEY_9 and highlight_active:
			set_label_big("9")
		elif (event.scancode == KEY_BACKSPACE or event.scancode == KEY_DELETE) and highlight_active:
			set_label_big(" ")
	if event is InputEventKey and highlight_active and event.is_pressed() and not event.is_echo():
		if event.scancode == KEY_LEFT:
			if highlight_coord.x > 0:
				highlight_coord.x = highlight_coord.x-1
			else:
				highlight_coord.x = 8
			move_rect()
		elif event.scancode == KEY_RIGHT:
			if highlight_coord.x < 8:
				highlight_coord.x = highlight_coord.x+1
			else:
				highlight_coord.x = 0
			move_rect()
		elif event.scancode == KEY_UP:
			if highlight_coord.y > 0:
				highlight_coord.y = highlight_coord.y-1
			else:
				highlight_coord.y = 8
			move_rect()
		elif event.scancode == KEY_DOWN:
			if highlight_coord.y < 8:
				highlight_coord.y = highlight_coord.y+1
			else:
				highlight_coord.y = 0
			move_rect()
	#this is for the eventual markup mode
#	elif event is InputEventKey and puzzles[str(puzzle_difficulty)][str(puzzle_num)][highlight_coord.y*9 + highlight_coord.x] == " ":
#			set_label_small("1")

#moves the gray bars to coord(+2 to offset rect_highlight border)
func move_indicator_lines():
	indicator_rect_column.set_position(Vector2(coord.x*cell_size+2,2))
	indicator_rect_row.set_position(Vector2(2,coord.y*cell_size+2))

#moves rect_highlight to highlight_coord (+2 to offset rect_highlight border)
func move_rect():
	rect_highlight.set_position(Vector2(highlight_coord.x*cell_size+2,highlight_coord.y*cell_size+2))
#	print("rect location: " + str(Vector2(coord.x*cell_size+2,coord.y*cell_size+2)))

#when markup button pressed change button and markup_status
func _on_Markup_button_pressed():
	if markup_status:
		markup_button["custom_styles/normal"].bg_color = Color("#930606")
		markup_button["custom_styles/pressed"].bg_color = Color("#7f0606")
		markup_button["custom_styles/hover"].bg_color = Color("#890606")
	else:
		markup_button["custom_styles/normal"].bg_color = Color("#069306")
		markup_button["custom_styles/pressed"].bg_color = Color("#067f06")
		markup_button["custom_styles/hover"].bg_color = Color("#068906")
	markup_status = not markup_status

#when edit button pressed change button color and highlight_active
func _on_RIN_button_pressed():
	if highlight_active:
		rin_button["custom_styles/normal"].bg_color = Color("#930606")
		rin_button["custom_styles/pressed"].bg_color = Color("#7f0606")
		rin_button["custom_styles/hover"].bg_color = Color("#890606")
	else:
		rin_button["custom_styles/normal"].bg_color = Color("#069306")
		rin_button["custom_styles/pressed"].bg_color = Color("#067f06")
		rin_button["custom_styles/hover"].bg_color = Color("#068906")
	highlight_active = not highlight_active
	rect_highlight.visible = highlight_active

#save work, remove labels from scene, and then go back to main menu
func _on_Main_Menu_button_pressed():
	#save puzzle to json
	save_work()
	#remove labels
	label_cleanup()
	#change scene
	get_tree().change_scene("res://Scenes/Main Menu.tscn")

#saves progress to file
func save_work():
	var string = ""
	#loop through all labels
	for i in 81:
		#if the label isn't blank and the the label doesn't have a number from puzzle in it
		if puzzles[str(puzzle_difficulty)][str(puzzle_num)][i] == "." and label_array[80-i].get_text() != "" and label_array[80-i].get_text() != " ":
			#string += label_array[i] text
			string = str(string,label_array[80-i].get_text())
		else:
			#otherwise just put a space as a placeholder
			string = str(string, ".")
			#the actual saving portion
	user_puzzles[str(puzzle_difficulty)][str(puzzle_num)][1] = string
	#file saving boilerplate
	var file = File.new()
	var error = file.open(user_data_path,File.WRITE)
	if error == OK:
		file.store_line(to_json(user_puzzles))
	file.close()
	error = file.open(last_puzzle_path,File.WRITE)
	if error == OK:
		var dict = {"difficulty": str(puzzle_difficulty),"puzzle_num": str(puzzle_num)}
		file.store_line(to_json(dict))
	file.close()

#removes all labels from grid
func label_cleanup():
	for i in 81:
		grid.remove_child(label_array[i])
		label_array[i] = null

#create labels and populate the grid with them
func label_setup():
	#create 81 new labels and fix their properties
	for i in 81:
		label_array[i] = Label.new()
		label_array[i].set_align(1)
		label_array[i].set_valign(1)
		label_array[i].rect_min_size = Vector2(52,52)
		label_array[i].add_font_override("font",load("res://Fonts/my_font.tres"))
		label_array[i]["custom_colors/font_color"] = Color("#000000")
	#add all the new labels to the grid
	for i in range(80,-1,-1):
		grid.add_child(label_array[i])

#sets color of and text of labels from puzzles and user_puzzles
func set_label_puzzle_data():
	#loop through all json data
	for i in 81:
		#if the number in the puzzle and user_puzzle isn't blank, set the label it corresponds to to that number
		if puzzles[str(puzzle_difficulty)][str(puzzle_num)][i] != ".":
			label_array[80-i].set_text(puzzles[str(puzzle_difficulty)][str(puzzle_num)][i])
			label_array[80-i]["custom_colors/font_color"] = Color("#000000")
		elif user_puzzles[str(puzzle_difficulty)][str(puzzle_num)][1][i] != ".":
			label_array[80-i].set_text(user_puzzles[str(puzzle_difficulty)][str(puzzle_num)][1][i])
			label_array[80-i]["custom_colors/font_color"] = Color("#ff0000")

#retrieve puzzle data
func get_puzzle():
	#open puzzles.json
	var file = File.new()
	if file.file_exists(puzzles_path):
		var error = file.open(puzzles_path,File.READ)
		#if it opened fine
		if error == OK:
			#put json data into puzzles dictionary
			var text = file.get_as_text()
			puzzles = parse_json(text)
		file.close()
	#open user_puzzles.json
	if file.file_exists(user_data_path):
		var error = file.open(user_data_path,File.READ)
		#if it opened fine
		if error == OK:
			#put json data into user_puzzles dictionary
			var text = file.get_as_text()
			user_puzzles = parse_json(text)
			if not user_puzzles.has(str(puzzle_difficulty)) or not user_puzzles[str(puzzle_difficulty)].has(str(puzzle_num)):
				user_puzzles[str(puzzle_difficulty)][str(puzzle_num)] = ["",""]
				user_puzzles[str(puzzle_difficulty)][str(puzzle_num)][0] = "0"
				user_puzzles[str(puzzle_difficulty)][str(puzzle_num)][1] = "................................................................................."
		file.close()
	if user_puzzles[str(puzzle_difficulty)][str(puzzle_num)][0] == "0":
		completed_label.set_text("No")
	else:
		completed_label.set_text("Yes")

#set the text of a label in the grid
func set_label_big(num):
	#index = label position
	var index = 80 - (highlight_coord.y*9 + highlight_coord.x)
	label_array[index].set_text(num)
	label_array[index]["custom_colors/font_color"] = Color("#ff0000")

#set text of a label in the grid (for markup)
#func set_label_small(num):
#	var index = 80 - (highlight_coord.y*9 + highlight_coord.x)

#run when the check! button is pressed, sets label underneath it to complete or incomplete
func _on_Check_Work_button_pressed():
	if check_completion():
		check_status_label.set_text("Complete")
	else:
		check_status_label.set_text("Incomplete")

#check puzzle completion
func check_completion():
	#check against completed puzzle
	for i in 81:
		if puzzle_solutions[str(puzzle_difficulty)][str(puzzle_num)][i] != label_array[80-i].get_text():
			user_puzzles[str(puzzle_difficulty)][str(puzzle_num)][0] = "0"
			completed_label.set_text("No")
			return false
	user_puzzles[str(puzzle_difficulty)][str(puzzle_num)][0] = "1"
	completed_label.set_text("Yes")
	return true
