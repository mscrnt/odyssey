extends Node

func initialize(player):
	for i in range(get_child_count()):
		var room = get_child(i)
		if room is GameRoom:
			room.player = player  # Set the player reference in each GameRoom

func _ready() -> void:
	# Home
	var home_room = $Home
#	home_room.connect_exit_unlocked("central avalonia", $"Avalonia/Central Avalonia", "home")
	
	## World - Avalonia
	
	# Central Avalonia
	var central_avalonia_room = $"Avalonia/Central Avalonia"
	central_avalonia_room.connect_exit_unlocked("grand castle", $"Avalonia/Grand Castle", "central avalonia")
	central_avalonia_room.connect_exit_unlocked("mystic market", $"Avalonia/Mystic Market", "central avalonia")
	var sewer_exit = central_avalonia_room.connect_exit_locked("sewers", $Avalonia/Sewers, "central avalonia")
	central_avalonia_room.connect_exit_unlocked("hall of elders", $"Avalonia/Hall of Elders", "central avalonia")
	
	# Add NPCs to Central Avalonia
	var athena = load_npc("Athena")
	central_avalonia_room.add_npc(athena)
	athena.quest_reward = sewer_exit
	
	# The Grand Castle
	var grand_castle_room = $"Avalonia/Grand Castle"
	grand_castle_room.connect_exit_unlocked("throne room", $"Avalonia/Throne Room", "grand castle")
	grand_castle_room.connect_exit_unlocked("royal library", $"Avalonia/Royal Library", "grand castle")
	grand_castle_room.connect_exit_unlocked("grand courtyard", $"Avalonia/Grand Courtyard", "grand castle")
	
	# Add NPCs to The Grand Castle
	var monk = load_npc("Monk")
	grand_castle_room.add_npc(monk)
	
	# The Royal Library
	var royal_library_room = $"Avalonia/Royal Library"
	var chamber_exit = royal_library_room.connect_exit_locked("secret chamber", $"Avalonia/Secret Chamber", "royal library")
	var key = load_item("SecretChamberKey")
	key.use_value = chamber_exit
	royal_library_room.add_item(key)
	
	# Secret Chamber
	var secret_chamber_room = $"Avalonia/Secret Chamber"
	var sword = load_item("AthenaSword")
	secret_chamber_room.add_item(sword)
	secret_chamber_room.connect_exit_unlocked("sewers", $Avalonia/Sewers, "secret chamber")
	
	# TODO: Update other room connections and items/NPCs as necessary

func load_item(item_name: String):
	return load("res://items/" + item_name + ".tres")
	
func load_npc(npc_name: String):
	return load("res://npcs/" + npc_name + ".tres")

