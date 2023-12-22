extends Node


func _ready() -> void:
	var key = Item.new()
	key.initialize("key", Types.ItemTypes.KEY, "An old brass key.")

	
	## World - Odyssey VR
	
	# Home
	$"Home".connect_exit_unlocked("avalonia", $"Central Avalonia", "home")
	
	## World - AVALONIA
	
	# Central Avalonia
	$"Central Avalonia".connect_exit_unlocked("castle", $"Grand Castle", "avalonia")
	$"Central Avalonia".connect_exit_unlocked("market", $"Mystic Market", "avalonia")
	$"Central Avalonia".connect_exit_locked("sewers", $"Secret Chamber", "avalonia")
	$"Central Avalonia".connect_exit_unlocked("elders", $"Hall of Elders", "avalonia")
	
	
	# Mystic Market
	# TODO
	
	# The Grand Castle
	$"Grand Castle".connect_exit_unlocked("throne", $"Throne Room", "castle")
	$"Grand Castle".connect_exit_unlocked("library", $"Royal Library", "castle")
	$"Grand Castle".connect_exit_unlocked("courtyard", $"Grand Courtyard", "castle")
	
	# The Royal Library
	var exit = $"Royal Library".connect_exit_locked("chamber", $"Secret Chamber", "library")
	key.use_value = exit
	$"Royal Library".add_item(key)
	
