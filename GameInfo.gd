# GameInfo.gd

extends PanelContainer

const INPUT_RESPONSE = preload("res://input/InputResponse.tscn")

export (int) var max_lines_remembered := 30
var max_scroll_length := 0
var should_zebra := true

onready var scroll = $Scroll
onready var scrollbar = scroll.get_v_scrollbar()
onready var history_rows = $Scroll/HistoryRows

func get_history_rows() -> VBoxContainer:
	return history_rows
	
func _ready() -> void:
	scrollbar.connect("changed", self, "_handle_scrollbar_change")
	max_scroll_length = scrollbar.max_value


##### PUBLIC #####
func create_response(response_text: String):
	var response = INPUT_RESPONSE.instance()
	_add_response_to_game(response)
	response.set_text(response_text)


func create_response_with_input(response_text: String, input_text: String):
	var input_response = INPUT_RESPONSE.instance()
	_add_response_to_game(input_response)
	input_response.set_text(response_text, input_text)

func get_history_data() -> Array:
	var history_data = []
	for child in history_rows.get_children():
		history_data.append(child.get_save_data())
	return history_data

# This function will recreate the history from the saved data
func restore_history(history_data: Array) -> void:
	# First, clear the current history
	for child in history_rows.get_children():
		child.queue_free()

	# Now, recreate each response from the saved data
	for data in history_data:
		if data.has("response_text"):
			if data["input_text"] == "":
				create_response(data["response_text"])
			else:
				create_response_with_input(data["response_text"], data["input_text"])
				
func reset_state():
	# Clear the history of responses
	for child in history_rows.get_children():
		child.queue_free()

	# Reset any other necessary state variables
	max_scroll_length = 0
	should_zebra = true

	# Optionally, you can add a default welcome or reset message
	#create_response("Game reset. Welcome back!")
##### PRIVATE #####
func _handle_scrollbar_change():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		scroll.scroll_vertical = scrollbar.max_value
		
func _delect_history_beyond_limit():
	if history_rows.get_child_count() > max_lines_remembered:
		var rows_to_forget = history_rows.get_child_count() - max_lines_remembered
		for i in range(rows_to_forget):
			history_rows.get_child(i).queue_free()

func _add_response_to_game(response: Control):
	history_rows.add_child(response)
	if not should_zebra:
		response.zebra.hide()
	should_zebra = !should_zebra
	_delect_history_beyond_limit()
	
