extends Control


onready var game_info = $Background/MarginContainer/Columns/GameRows/GameInfo
onready var command_processor = $CommandProcessor
onready var room_manager = $RoomManager
onready var player = $Player

func _ready() -> void:
	var info_rows = $Background/MarginContainer/Columns/InfoRows

	command_processor.connect("room_changed", info_rows, "handle_room_changed")	
	command_processor.connect("room_updated", info_rows, "handle_room_updated")	
	game_info.create_response(Types.wrap_system_text("Welcome to Odyssey! You are currently in your Home. A recent email from your friend Athena has caught your attention. She urgently needs to meet with you in Avalonia. To embark on this adventure, use the 'portal' command followed by the destination to fast travel. For instance, type 'portal avalonia' to travel there. Remember, you can view a list of available commands anytime by typing 'help'. Good luck on your journey!"))
	player.connect_portal("avalonia", $"RoomManager/Avalonia/Central Avalonia")
	player.connect_portal("home", $RoomManager/Home)
	command_processor.room_manager = room_manager
	room_manager.initialize(player)
	var starting_room_response = command_processor.initialize(room_manager.get_child(0), player)

	game_info.create_response(starting_room_response)
	command_processor.room_manager = room_manager


func _on_Input_text_entered(new_text: String) -> void:
	if new_text.empty():
		return

	var response = command_processor.process_command(new_text)		
	game_info.create_response_with_input(response, new_text)		


