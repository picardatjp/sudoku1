extends Control

onready var puzzle_select_popup = $ColorRect/Puzzle_select_popup
onready var list = $ColorRect/Puzzle_select_popup/List
onready var puzzle_selected_label = $ColorRect/Puzzle_selected_label
onready var puzzle_selected_difficulty = $ColorRect/Puzzle_selected_difficulty
onready var confirm_dialog = $ColorRect/ConfirmationDialog

var puzzles_path = Globals.puzzles_path
var user_data_path = Globals.user_data_path
var difficulty_selected = Globals.puzzle_difficulty
var puzzle_selected = Globals.puzzle_num
var puzzles = {}

func _ready():
	var file = File.new()
	var error = file.open(puzzles_path,File.READ)
	if error == OK:
		var text = file.get_as_text()
		puzzles = parse_json(text)
	file.close()
	puzzle_selected_label.set_text(str(puzzle_selected))
	if Globals.puzzle_difficulty == 1:
		puzzle_selected_difficulty.set_text("Easy")
	elif Globals.puzzle_difficulty == 2:
		puzzle_selected_difficulty.set_text("Medium")
	elif Globals.puzzle_difficulty == 3:
		puzzle_selected_difficulty.set_text("Hard")

func _on_Play_button_pressed():
	get_tree().change_scene("res://Scenes/Game.tscn")

func _on_Puzzle_select_button_pressed():
	puzzle_select_popup.visible = true
	populate_list()

func _on_Select_button_pressed():
	var selected = list.get_selected_items()
	if selected.size() > 0:
		Globals.puzzle_num = selected[0]+1
		puzzle_select_popup.visible = false

func populate_list():
	for key in puzzles[str(Globals.puzzle_difficulty)].keys():
		list.add_item(key,null,true)

func _on_Hard_button_pressed():
	list.clear()
	Globals.puzzle_difficulty = 3
	populate_list()

func _on_Medium_button_pressed():
	list.clear()
	Globals.puzzle_difficulty = 2
	populate_list()

func _on_Easy_button_pressed():
	list.clear()
	Globals.puzzle_difficulty = 1
	populate_list()

func _on_Puzzle_select_popup_visibility_changed():
	puzzle_selected_label.set_text(str(Globals.puzzle_num))
	if Globals.puzzle_difficulty == 1:
		puzzle_selected_difficulty.set_text("Easy")
	elif Globals.puzzle_difficulty == 2:
		puzzle_selected_difficulty.set_text("Medium")
	elif Globals.puzzle_difficulty == 3:
		puzzle_selected_difficulty.set_text("Hard")
	list.clear()


func _on_ConfirmationDialog_confirmed():
	var file = File.new()
	var error = file.open(user_data_path,File.READ_WRITE)
	if error == OK:
		var text = file.get_as_text()
		var user_puzzles = parse_json(text)
		user_puzzles[str(difficulty_selected)][str(puzzle_selected)] = "                                                                                 "
		file.store_line(to_json(user_puzzles))
		print("data cleared")
	file.close()

func _on_Clear_puzzle_data_button_pressed():
	confirm_dialog.visible = true
