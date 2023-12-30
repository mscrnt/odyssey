# RoomManager.gd

extends Node

func initialize(player, room_manager_instance):
	for i in range(get_child_count()):
		var room = get_child(i)
		if room is GameRoom:
			room.player = player
			room.room_manager = room_manager_instance


# Rooms
onready var home_room = $Home
onready var central_avalonia_room = $"Avalonia/Central Avalonia"
onready var royal_library_room = $"Avalonia/Royal Library"
onready var grand_courtyard_room = $"Avalonia/Grand Courtyard"
onready var throneroom_room = $"Avalonia/Throne Room"
onready	var grand_castle_room = $"Avalonia/Grand Castle"
onready	var mystic_market_room = $"Avalonia/Mystic Market"
onready var secret_chamber_room = $"Avalonia/Secret Chamber"
onready	var hall_of_elders_room = $"Avalonia/Hall of Elders"
onready	var sewers_room = $Avalonia/Sewers

var item_use_value_map: Dictionary = {}


func _ready() -> void:
	# use_value
	var chamber_exit = royal_library_room.connect_exit_locked("secret chamber", $"Avalonia/Secret Chamber", "royal library")

	# quest_reward
	var sewer_exit = central_avalonia_room.connect_exit_locked("sewers", $Avalonia/Sewers, "central avalonia")

	# NPCs
	var athena = load_npc("Athena")
	var monk = load_npc("Monk")

	# Items
	var key = load_item("SecretChamberKey")
	var sword = load_item("AthenaSword")
	
	# Central Avalonia
	central_avalonia_room.connect_exit_unlocked("grand castle", $"Avalonia/Grand Castle", "central avalonia")
	central_avalonia_room.connect_exit_unlocked("mystic market", $"Avalonia/Mystic Market", "central avalonia")

	central_avalonia_room.connect_exit_unlocked("hall of elders", $"Avalonia/Hall of Elders", "central avalonia")
	
	# Add NPCs to Central Avalonia
	central_avalonia_room.add_npc(athena)
	athena.quest_reward = sewer_exit
	
	# The Grand Castle
	grand_castle_room.connect_exit_unlocked("throne room", $"Avalonia/Throne Room", "grand castle")
	grand_castle_room.connect_exit_unlocked("royal library", $"Avalonia/Royal Library", "grand castle")
	grand_castle_room.connect_exit_unlocked("grand courtyard", $"Avalonia/Grand Courtyard", "grand castle")
	
	# Add NPCs to The Grand Castle

	grand_castle_room.add_npc(monk)
	
	# The Royal Library
	key.use_value = chamber_exit
	royal_library_room.add_item(key)
	item_use_value_map["SecretChamberKey"] = chamber_exit

	# Secret Chamber


	secret_chamber_room.add_item(sword)
	secret_chamber_room.connect_exit_unlocked("sewers", $Avalonia/Sewers, "secret chamber")

func get_use_value_for_item(item_name: String) -> Exit:
	var mapping = item_use_value_map.get(item_name)
	if mapping:
		return mapping
	return null

func load_item(item_name: String):
	return load("res://items/" + item_name + ".tres")
	
func load_npc(npc_name: String):
	return load("res://npcs/" + npc_name + ".tres")

func get_room_state() -> Array:
	var room_states = []
	for i in range(get_child_count()):
		var room = get_child(i)
		if room:
			var room_state = room.get_room_state()
			room_states.append(room_state)
	return room_states

func get_all_rooms() -> Array:
	var all_rooms = []
	for i in range(get_child_count()):
		var child = get_child(i)
		if child is GameRoom:
			all_rooms.append(child)
	return all_rooms

func set_room_state(room_states: Array) -> void:
	for room_state in room_states:
		var room_path = room_state.get("path", "")
		var room = get_node_or_null(room_path)
		if room:
			room.set_room_state(room_state)
