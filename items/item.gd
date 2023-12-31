# Item.gd

extends Resource
class_name Item


export (String) var item_name := "Item Name"
export (String) var display_name := "Display Name"
export (Types.ItemTypes) var item_type := Types.ItemTypes.KEY
export (bool) var is_single_use := false
export (String, MULTILINE) var item_description := "Item Description"
export (String, MULTILINE) var examine_text = "This is text that appears when you examine this item."

var use_value = null


func initialize(item_name: String, item_type: int, item_description):
	self.item_name = item_name
	self.item_type = item_type
	self.item_description = item_description

# Inside get_item_state() method
func get_item_state() -> Dictionary:
	var state = {
		"item_name": item_name,
		"item_type": item_type,
		"is_single_use": is_single_use,
		"item_description": item_description,
		"use_value_room_1": use_value.room_1.room_name if use_value else "",
		"use_value_room_2": use_value.room_2.room_name if use_value else ""
	}
	return state


func set_item_state(state: Dictionary, room_manager) -> void:
	if state.has("item_name"):
		item_name = state["item_name"]
	if state.has("item_type"):
		item_type = state["item_type"]
	if state.has("is_single_use"):
		is_single_use = state["is_single_use"]
	if state.has("item_description"):
		item_description = state["item_description"]
	if state.has("use_value_room_1") and state.has("use_value_room_2"):
		var room_1_name = state["use_value_room_1"]
		var room_2_name = state["use_value_room_2"]
		if room_1_name != "" and room_2_name != "":
			use_value = room_manager.get_use_value_for_item(item_name)
			if use_value == null:
				printerr("Failed to set use_value for item:", item_name)


