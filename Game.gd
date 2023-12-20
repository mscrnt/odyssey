extends Control

const Response = preload("res://Response.tscn")
const InputResponse = preload("res://InputResponse.tscn")

export (int) var max_lines_remembered := 30

var max_scroll_length := 0

onready var command_processor = $CommandProcessor
onready var history_rows = $Background/MarginContainer/Columns/InventoryRows/GameInfo/Scroll/HistoryRows
onready var scroll = $Background/MarginContainer/Columns/InventoryRows/GameInfo/Scroll
onready var scrollbar = scroll.get_v_scrollbar()

func _ready() -> void:
	scrollbar.connect("changed", self, "handle_scrollbar_change")
	max_scroll_length = scrollbar.max_value
	var starting_message = Response.instance()
	starting_message.text = "You find yourself in your VR Lobby. The logout button does not work. You need to find your way out. You can type 'help' to see you available commands."
	add_response_to_game(starting_message)
	

func handle_scrollbar_change():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		scroll.scroll_vertical = scrollbar.max_value

func _on_Input_text_entered(new_text: String) -> void:
	if new_text.empty():
		return
		
	var input_response = InputResponse.instance()
	var response = command_processor.process_command(new_text)
	input_response.set_text(new_text, response)
	add_response_to_game(input_response)


func add_response_to_game(response: Control):
	history_rows.add_child(response)
	delect_history_beyond_limit()
	

func delect_history_beyond_limit():
	if history_rows.get_child_count() > max_lines_remembered:
		var rows_to_forget = history_rows.get_child_count() - max_lines_remembered
		for i in range(rows_to_forget):
			history_rows.get_child(i).queue_free()
