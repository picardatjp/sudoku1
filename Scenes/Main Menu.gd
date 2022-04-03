extends Control

onready var puzzle_select_popup = $ColorRect/Puzzle_select_popup
onready var list = $ColorRect/Puzzle_select_popup/List
onready var puzzle_selected_label = $ColorRect/Puzzle_selected_label
onready var puzzle_selected_difficulty = $ColorRect/Puzzle_selected_difficulty
onready var confirm_dialog = $ColorRect/ConfirmationDialog
onready var completed_label = $ColorRect/Completed_label

var puzzles_path = Globals.puzzles_path
var user_data_path = Globals.user_data_path
var last_puzzle_path = Globals.last_puzzle_path
var difficulty_selected = Globals.puzzle_difficulty
var puzzle_selected = Globals.puzzle_num
var puzzles = {}
var user_puzzles = {}

func _ready():
	var file = File.new()
	var error = file.open(puzzles_path,File.READ)
	if error == OK:
		var text = file.get_as_text()
		puzzles = parse_json(text)
	file.close()
	error = file.open(user_data_path,File.READ)
	if error == OK:
		var text = file.get_as_text()
		user_puzzles = parse_json(text)
	file.close()
	error = file.open(last_puzzle_path,File.READ)
	if error == OK:
		var text = file.get_as_text()
		var dict = parse_json(text)
		Globals.puzzle_difficulty = int(dict["difficulty"])
		Globals.puzzle_num = int(dict["puzzle_num"])
	if user_puzzles[str(Globals.puzzle_difficulty)][str(Globals.puzzle_num)][0] == "1":
		completed_label.set_text("Yes")
	else:
		completed_label.set_text("No")
	
	puzzle_selected_label.set_text(str(Globals.puzzle_num))
	if Globals.puzzle_difficulty == 0:
		puzzle_selected_difficulty.set_text("Easy")
	elif Globals.puzzle_difficulty == 1:
		puzzle_selected_difficulty.set_text("Medium")
	elif Globals.puzzle_difficulty == 2:
		puzzle_selected_difficulty.set_text("Hard")

func _on_Play_button_pressed():
	get_tree().change_scene("res://Scenes/Game.tscn")

#func _on_Puzzle_select_button_pressed():
#	puzzle_select_popup.visible = true
#	populate_list()

func _on_Select_button_pressed():
	var selected = list.get_selected_items()
	if selected.size() > 0:
		Globals.puzzle_num = selected[0]+1
		Globals.puzzle_difficulty = difficulty_selected
		if not user_puzzles.has(str(Globals.puzzle_difficulty)) or not user_puzzles[str(Globals.puzzle_difficulty)].has(str(Globals.puzzle_num)):
			user_puzzles[str(Globals.puzzle_difficulty)][str(Globals.puzzle_num)] = ["",""]
			user_puzzles[str(Globals.puzzle_difficulty)][str(Globals.puzzle_num)][0] = "0"
			user_puzzles[str(Globals.puzzle_difficulty)][str(Globals.puzzle_num)][1] = "................................................................................."
		if user_puzzles[str(Globals.puzzle_difficulty)][str(Globals.puzzle_num)][0] == "1":
			completed_label.set_text("Yes")
		else:
			completed_label.set_text("No")
		puzzle_select_popup.visible = false
		
func select_puzzle():
	if not user_puzzles.has(str(Globals.puzzle_difficulty)) or not user_puzzles[str(Globals.puzzle_difficulty)].has(str(Globals.puzzle_num)):
		user_puzzles[str(Globals.puzzle_difficulty)][str(Globals.puzzle_num)] = ["",""]
		user_puzzles[str(Globals.puzzle_difficulty)][str(Globals.puzzle_num)][0] = "0"
		user_puzzles[str(Globals.puzzle_difficulty)][str(Globals.puzzle_num)][1] = "................................................................................."
	if user_puzzles[str(Globals.puzzle_difficulty)][str(Globals.puzzle_num)][0] == "1":
		completed_label.set_text("Yes")
	else:
		completed_label.set_text("No")

#func populate_list():
#	for key in puzzles[str(Globals.puzzle_difficulty)].keys():
#		list.add_item(key,null,true)

func _on_Hard_button_pressed():
	#list.clear()
	#difficulty_selected = 2
	#populate_list()
	difficulty_selected = 2
	Globals.puzzle_difficulty = difficulty_selected
	randomize()
	puzzle_selected = randi()%(puzzles[str(difficulty_selected)].size())+1
	Globals.puzzle_num = puzzle_selected
	puzzle_selected_label.set_text(str(Globals.puzzle_num))
	puzzle_selected_difficulty.set_text("Hard")
	select_puzzle()

func _on_Medium_button_pressed():
	#list.clear()
	#ifficulty_selected = 1
	#populate_list()
	difficulty_selected = 1
	Globals.puzzle_difficulty = difficulty_selected
	randomize()
	puzzle_selected = randi()%(puzzles[str(difficulty_selected)].size())+1
	Globals.puzzle_num = puzzle_selected
	puzzle_selected_label.set_text(str(Globals.puzzle_num))
	puzzle_selected_difficulty.set_text("Medium")
	select_puzzle()

func _on_Easy_button_pressed():
	#list.clear()
	#difficulty_selected = 0
	#populate_list()
	difficulty_selected = 0
	Globals.puzzle_difficulty = difficulty_selected
	randomize()
	puzzle_selected = randi()%(puzzles[str(difficulty_selected)].size())+1
	Globals.puzzle_num = puzzle_selected
	puzzle_selected_label.set_text(str(Globals.puzzle_num))
	puzzle_selected_difficulty.set_text("Easy")
	select_puzzle()

#func _on_Puzzle_select_popup_visibility_changed():
#	puzzle_selected_label.set_text(str(Globals.puzzle_num))
#	if Globals.puzzle_difficulty == 0:
#		puzzle_selected_difficulty.set_text("Easy")
#	elif Globals.puzzle_difficulty == 1:
#		puzzle_selected_difficulty.set_text("Medium")
#	elif Globals.puzzle_difficulty == 2:
#		puzzle_selected_difficulty.set_text("Hard")
#	list.clear()

#func _on_ConfirmationDialog_confirmed():
#	var file = File.new()
#	var error = file.open(user_data_path,File.READ_WRITE)
#	if error == OK:
#		var text = file.get_as_text()
#		user_puzzles = parse_json(text)
#		user_puzzles[str(difficulty_selected)][str(puzzle_selected)][1] = "................................................................................."
#		file.store_line(to_json(user_puzzles))
#		print("data cleared")
#	file.close()


#func _on_Clear_puzzle_data_button_pressed():
#	confirm_dialog.visible = true

#func _on_random_button_pressed():
#	randomize()
#	difficulty_selected = randi()%(puzzles.size())
#	Globals.puzzle_difficulty = difficulty_selected
#	randomize()
#	puzzle_selected = randi()%(puzzles[str(difficulty_selected)].size())+1
#	Globals.puzzle_num = puzzle_selected
#	puzzle_select_popup.visible = false



func _on_How_to_button_pressed():
	pass # Replace with function body.


func _on_Settings_button_pressed():
	pass # Replace with function body.
