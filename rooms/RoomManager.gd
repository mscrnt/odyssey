extends Node


func _ready() -> void:
	
	## World - Odyssey VR
	
	# Home
	$"Home".connect_exit_unlocked("avalonia", $"Central Avalonia", "home")
	
	## World - AVALONIA
	
	# Central Avalonia
	$"Central Avalonia".connect_exit_unlocked("castle", $"Grand Castle", "avalonia")
	$"Central Avalonia".connect_exit_unlocked("market", $"Mystic Market", "avalonia")
	var sewer_exit = $"Central Avalonia".connect_exit_locked("sewers", $"Secret Chamber", "avalonia")
	$"Central Avalonia".connect_exit_unlocked("elders", $"Hall of Elders", "avalonia")
	
	var athena = load_npc("Athena")
	$"Central Avalonia".add_npc(athena)
	athena.quest_reward = sewer_exit
	
	
	# Mystic Market
	# TODO
	
	# The Grand Castle
	$"Grand Castle".connect_exit_unlocked("throne", $"Throne Room", "castle")
	$"Grand Castle".connect_exit_unlocked("library", $"Royal Library", "castle")
	$"Grand Castle".connect_exit_unlocked("courtyard", $"Grand Courtyard", "castle")
	
	var monk = load_npc("Monk")
	$"Grand Castle".add_npc(monk)
	
	# The Royal Library
	var chamber_exit = $"Royal Library".connect_exit_locked("chamber", $"Secret Chamber", "library")
	var key = load_item("SecretChamberKey")
	key.use_value = chamber_exit
	$"Royal Library".add_item(key)
	
	# Secret Chamber
	var sword = load_item("AthenaSword")
	$"Secret Chamber".add_item(sword)
	

func load_item(item_name: String):
	return load("res://items/" + item_name + ".tres")
	
func load_npc(npc_name: String):
	return load("res://npcs/" + npc_name + ".tres")
