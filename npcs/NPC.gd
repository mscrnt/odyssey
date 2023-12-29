# NPC.gd

extends Resource
class_name NPC

export (String) var npc_name = "NPC Name"
export (String) var display_name = "Display Name"
export (String, MULTILINE) var npc_description = "NPC Description"
export (String, MULTILINE) var examine_text = "This is text that appears when you examine this npc."

export (String, MULTILINE) var initial_dialog
export (String, MULTILINE) var post_quest_dialog

export (Resource) var quest_item

var has_received_quest_item := false

var quest_reward = null

func get_npc_state() -> Dictionary:
	var state = {
		"npc_name": npc_name,
		"has_received_quest_item": has_received_quest_item
	}
	return state

func set_npc_state(state: Dictionary) -> void:
	if state.has("npc_name"):
		npc_name = state["npc_name"]
	if state.has("has_received_quest_item"):
		has_received_quest_item = state["has_received_quest_item"]

