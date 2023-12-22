extends PanelContainer

const INPUT_RESPONSE = preload("res://input/InputResponse.tscn")

export (int) var max_lines_remembered := 30
var max_scroll_length := 0

onready var scroll = $Scroll
onready var scrollbar = scroll.get_v_scrollbar()
onready var history_rows = $Scroll/HistoryRows


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
	_delect_history_beyond_limit()
	
