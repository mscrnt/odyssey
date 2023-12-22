extends Node


func _ready() -> void:
	var key = Item.new()
	key.initialize("key", Types.ItemTypes.KEY, "An old brass key.")
	key.use_value = $"Secret Chamber"
	
	## World - AVALONIA
	
	# Central Avalonia
	$"Central Avalonia".connect_exit_unlocked("north", $"Grand Castle")
	
	# The Grand Castle
	$"Grand Castle".connect_exit_unlocked("east", $"Royal Library")
	
	# The Royal Library
	$"Royal Library".connect_exit_locked("east", $"Secret Chamber")
	$"Royal Library".add_item(key)
