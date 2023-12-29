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

func get_item_state() -> Dictionary:
	return {
		"item_name": item_name,
		"item_type": item_type,
		"is_single_use": is_single_use,
		"item_description": item_description,
		"use_value": use_value
	}

func set_item_state(state: Dictionary) -> void:
	if state.has("item_name"):
		item_name = state["item_name"]
	if state.has("item_type"):
		item_type = state["item_type"]
	if state.has("is_single_use"):
		is_single_use = state["is_single_use"]
	if state.has("item_description"):
		item_description = state["item_description"]
	if state.has("use_value"):
		use_value = state["use_value"]
