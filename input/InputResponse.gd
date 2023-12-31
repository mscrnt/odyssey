#InputResponse.gd

extends MarginContainer

onready var zebra = $Zebra
onready var input_label = $Rows/InputHistory
onready var response_label = $Rows/Response

func set_text(response: String, input: String = ""):
	if input == "":
		input_label.queue_free()
	else:
		input_label.text = " > " + input

	response_label.bbcode_text = response

# This function will gather the necessary data to save
func get_save_data() -> Dictionary:
	var data = {}
	if is_instance_valid(response_label):
		data["response_text"] = response_label.bbcode_text
	else:
		data["response_text"] = ""
	
	if is_instance_valid(input_label):
		data["input_text"] = input_label.text
	else:
		data["input_text"] = ""
	
	return data

# This function will restore the state from the saved data
func set_from_save_data(data: Dictionary) -> void:
	if data.has("response_text"):
		response_label.bbcode_text = data["response_text"]
	if data.has("input_text") and input_label:
		input_label.text = data["input_text"]
