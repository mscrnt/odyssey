# GameRoom.gd

tool
extends PanelContainer
class_name GameRoom

export (String) var room_name = "Room Name" setget set_room_name
export (String) var display_name = "Display Name"
export (String) var world_name = "World Name"
export (String, MULTILINE) var room_description = "This is the description of the room." setget set_room_description
export (String, MULTILINE) var examine_text = "This is text that appears when you examine this room."
export (bool) var is_hub = false
export (bool) var is_hidden = false

var exits: Dictionary = {}
var npcs: Array = []
var items: Array = []
var is_current_room: bool = false 

var player = null

func get_room_state() -> Dictionary:
	var npc_states = []
	for npc in npcs:
		npc_states.append(npc.get_npc_state())
	
	var item_states = []
	for item in items:
		item_states.append(item.get_item_state())

	var state = {
		"room_name": room_name,
		"display_name": display_name,
		"room_description": room_description,
		"is_hub": is_hub,
		"is_hidden": is_hidden,
		"npc_states": npc_states,
		"item_states": item_states
	}
	return state

func set_room_state(state: Dictionary) -> void:
	if state.has("room_name"):
		room_name = state["room_name"]
	if state.has("display_name"):
		display_name = state["display_name"]
	if state.has("room_description"):
		room_description = state["room_description"]
	if state.has("is_hub"):
		is_hub = state["is_hub"]
	if state.has("is_hidden"):
		is_hidden = state["is_hidden"]
	if state.has("npc_states"):
		for npc_state in state["npc_states"]:
			# Find NPC by name or some unique identifier and set its state
			var npc = find_npc_by_name(npc_state["npc_name"])
			if npc:
				npc.set_npc_state(npc_state)
	if state.has("item_states"):
		for item_state in state["item_states"]:
			# Find Item by name or some unique identifier and set its state
			var item = find_item_by_name(item_state["item_name"])
			if item:
				item.set_item_state(item_state)
	# Restore other room-specific properties here

# Helper function to find NPC by name
func find_npc_by_name(name: String) -> NPC:
	for npc in npcs:
		if npc.npc_name == name:
			return npc
	return null

# Helper function to find Item by name
func find_item_by_name(name: String) -> Item:
	for item in items:
		if item.item_name == name:
			return item
	return null

func set_room_name(new_name: String):
	$MarginContainer/Rows/RoomName.text = new_name
	room_name = new_name
	
func set_room_description(new_description: String):
	$MarginContainer/Rows/RoomDescription.text = new_description
	room_description = new_description
	
func add_item(item: Item):
	items.append(item)
	
func remove_item(item: Item):
	items.erase(item)
	
func add_npc(npc: NPC):
	npcs.append(npc)
	
func remove_npc(npc: NPC):
	npcs.erase(npc)
	
func get_full_description() -> String:
	var full_description = PoolStringArray([get_room_description()])
	
	var npc_description = get_npc_description()
	if npc_description != "":
		full_description.append(npc_description)
	
	var item_description = get_item_description()
	if item_description != "":
		full_description.append(item_description)
	
	full_description.append(get_exit_description())
	
	var full_description_string = full_description.join("\n")
	return full_description_string

func get_room_description() -> String:
	return "You are now in: " + Types.wrap_location_text(room_name) + "." + "\n\n"+ "It is " + room_description + "\n"

func get_npc_description() -> String:
	if npcs.size() == 0:
		return ""
		
	var npc_string = ""
	for npc in npcs:
		if npc != npcs[npcs.size() - 1]:
			npc_string += Types.wrap_npc_text(npc.npc_name) + " | "
		else:
			npc_string += Types.wrap_npc_text(npc.npc_name)
	return "NPCs: " + npc_string + "\n"

func get_item_description() -> String:
	if items.size() == 0:
		return ""
		
	var item_string = ""
	for item in items:
		if item != items[items.size() - 1]:
			item_string += Types.wrap_item_text(item.display_name) + " | "
		else:
			item_string += Types.wrap_item_text(item.display_name)
	return "Items: " + item_string + "\n"


func get_exit_description() -> String:
	if room_name == "Home" and player:
		var fast_travel_locations = player.get_fast_travel_locations()
		
		# Filter out "home" from the fast travel locations
		fast_travel_locations.erase("home")

		var fast_travel_descriptions = PoolStringArray(fast_travel_locations).join("[/color] | [color=#f7c07c]")
		return "Portals: " + Types.wrap_portal_text(fast_travel_descriptions)
	else:
		# Default behavior for non-Home rooms
		var exit_keys = PoolStringArray(exits.keys()).join(" | ")
		return "Exits: " + Types.wrap_location_text(PoolStringArray(exits.keys()).join("[/color] | [color=#f7c07c]"))

func connect_exit_unlocked(direction: String, room, room_2_ovr_name = "null"):
	return _connect_exit(direction, room, false, room_2_ovr_name)

func connect_exit_locked(direction: String, room, room_2_ovr_name = "null"):
	return _connect_exit(direction, room, true, room_2_ovr_name)

func _connect_exit(direction: String, room, is_locked: bool = false, room_2_ovr_name = "null"):
	var exit = Exit.new()
	exit.room_1 = self
	exit.room_2 = room
	exit.room_2_is_locked = is_locked
	exits[direction] = exit
	
	if room_2_ovr_name != "null":
		room.exits[room_2_ovr_name] = exit
	else:
		match direction:
			"west":
				room.exits["east"] = exit
			"east":
				room.exits["west"] = exit
			"north":
				room.exits["south"] = exit
			"south":
				room.exits["north"] = exit
			"up":
				room.exits["down"] = exit
			"down":
				room.exits["up"] = exit
			"path":
				room.exits["path"] = exit
			"inside":
				room.exits["outside"] = exit
			"outside":
				room.exits["inside"] = exit
			_:
				printerr("Tried to connect invalid direction: %s", direction)
	
	return exit


		
	
	
