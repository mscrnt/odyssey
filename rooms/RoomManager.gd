extends Node


func _ready() -> void:
	var key = Item.new()
	key.initialize("Key", Types.ItemTypes.KEY, "An old brass key.")
	
	$"Central Avalonia".connect_exit("north", $"Grand Castle")
	$"Central Avalonia".add_item(key)
