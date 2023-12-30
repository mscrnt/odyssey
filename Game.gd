# Game.gd

extends Control

const INPUT_RESPONSE = preload("res://input/InputResponse.tscn")


onready var game_info = $Background/MarginContainer/UI/GameArea/GameRows/GameInfo
onready var command_processor = $CommandProcessor
onready var room_manager = $RoomManager
onready var player = $Player
onready var info_rows = $Background/MarginContainer/UI/GameArea/InfoRows
onready var inventory_panel = $Background/MarginContainer/UI/GameArea/InfoRows/InventoryPanel
onready var location_info_scene = preload("res://scenes/LocationInfo.tscn")
onready var inventory_info_scene = preload("res://scenes/InventoryInfo.tscn")
onready var file_window = preload("res://top_bar/FileWindow.tscn")
onready var file_window_instance: FileDialog = null
onready var info_label = $Background/MarginContainer/UI/GameArea/InfoRows/InventoryLabel/InfoLabel


var content_instances = {
	"Location Info": null,
	"Inventory": null
}

var content_labels = {
	"Location Info": "Location",
	"Inventory": "Inventory"
}

func _ready() -> void:
	setup_game()
	info_rows.dropdown_menu.connect("item_selected", self, "_on_dropdown_item_selected")
	info_rows.player = player 
	if not file_window_instance:
		file_window_instance = file_window.instance() as FileDialog
		get_tree().root.add_child(file_window_instance)
	file_window.connect("file_save_selected", self, "_on_FileSaveSelected")
	file_window.connect("file_load_selected", self, "_on_FileLoadSelected")
	player.room_manager = room_manager
	# Initialize the room info directly
	content_instances["Location Info"] = location_info_scene.instance()
	inventory_panel.add_child(content_instances["Location Info"])
	content_instances["Location Info"].update_room_info(room_manager.get_child(0))

	# Connect signals for room changes and updates
	command_processor.connect("room_changed", self, "_on_room_changed")
	command_processor.connect("room_updated", self, "_on_room_changed")

	command_processor.connect("inventory_changed", self, "_on_inventory_changed")



func setup_game() -> void:
	# Setup initial game state, connecting portals and initializing the room manager
	player.connect_portal("avalonia", $"RoomManager/Avalonia/Central Avalonia")
	player.connect_portal("home", $RoomManager/Home)
	command_processor.room_manager = room_manager
	room_manager.initialize(player, room_manager)

	var starting_room_response = command_processor.initialize(room_manager.get_child(0), player)
	var response = "A recent email from your friend, " + Types.wrap_npc_text("Athena") + ", has caught your attention. "
	response += "She urgently needs to meet with you in Avalonia. To embark on this adventure, use the " + Types.wrap_system_text("portal") + " command followed by the "
	response += Types.wrap_portal_text("world") + " you want to fast travel to.\n\n"
	response += "In this case, type '" + Types.wrap_system_text("portal ") + Types.wrap_portal_text("avalonia") + "' to travel there.\n\n"
	response += "You can always view a list of available commands by typing '" + Types.wrap_system_text("help") + "'.\n\n"
	response += "Good luck on your journey!"

	game_info.create_response(response)
	game_info.create_response(starting_room_response)


func _on_dropdown_item_selected(index: int) -> void:
	var selected_option = info_rows.dropdown_menu.get_item_text(index)
	show_content(selected_option)
	_update_info_label(selected_option)

func _update_info_label(selected_option: String) -> void:
	# Check if the selected option has a corresponding label
	if content_labels.has(selected_option):
		info_label.text = content_labels[selected_option]

func show_content(type: String) -> void:
	# Hide the current content
	if content_instances.has("current") and content_instances["current"] != null:
		content_instances["current"].visible = false

	# Check if the type already has an instance
	if content_instances[type] == null:
		# Create it if it does not exist
		if type == "Location Info":
			content_instances[type] = location_info_scene.instance()
		elif type == "Inventory":
			content_instances[type] = inventory_info_scene.instance()
		else:
			printerr("Invalid content type: " + type)
			return

		inventory_panel.add_child(content_instances[type])

	# Just make the existing instance visible
	content_instances[type].visible = true

	# Set the current content
	content_instances["current"] = content_instances[type]

	# Update display for inventory if selected
	if type == "Inventory":
		content_instances[type].update_inventory_display(player.get_inventory_list())

func _on_inventory_changed() -> void:
	# Check if the inventory display is currently visible
	if content_instances.has("Inventory") and content_instances["Inventory"] != null:
		# Update the inventory display
		content_instances["Inventory"].update_inventory_display(player.get_inventory_list())

func _on_room_changed(new_room) -> void:
	if content_instances["Location Info"]:
		content_instances["Location Info"].update_room_info(new_room)
		
func _on_Input_text_entered(new_text: String) -> void:
	if new_text.empty():
		return

	var response = command_processor.process_command(new_text)		
	game_info.create_response_with_input(response, new_text)
	
func get_game_state() -> Dictionary:
	var state = {
		"player_state": player.get_player_state(),
		"rooms_state": get_rooms_state(),
		"global_settings": get_global_settings(),
		"current_room": CurrentRoom.current_room.room_name
	}
	return state

func get_rooms_state() -> Dictionary:
	var rooms_state = {}
	# First, get the state of top-level rooms (e.g., 'Home')
	for i in range(room_manager.get_child_count()):
		var room = room_manager.get_child(i)
		if room is GameRoom:
			rooms_state[room.get_path()] = room.get_room_state()  # Use get_path() to uniquely identify rooms

	# Now, get the state of rooms nested within world nodes
	for i in range(room_manager.get_child_count()):
		var world_node = room_manager.get_child(i)
		if world_node.get_child_count() > 0:
			for j in range(world_node.get_child_count()):
				var nested_room = world_node.get_child(j)
				if nested_room is GameRoom:
					rooms_state[nested_room.get_path()] = nested_room.get_room_state()  # Use get_path() for nested rooms as well

	return rooms_state
	
func get_room_by_name(room_name: String) -> GameRoom:
	for i in range(room_manager.get_child_count()):
		var world_node = room_manager.get_child(i)
		for j in range(world_node.get_child_count()):
			var child = world_node.get_child(j)
			if child is GameRoom and child.room_name == room_name:
				return child
	return null
	
func get_hub_from_world(world_name: String) -> GameRoom:
	
	if world_name.to_lower() == "home":
		var home_room = room_manager.get_node("Home")  
		if home_room:
			return home_room
			
	var world_node = null
	for i in range(room_manager.get_child_count()):
		var child = room_manager.get_child(i)
		if child.name.to_lower() == world_name.to_lower():
			world_node = child
			break

	if world_node:
		for child in world_node.get_children():
			if child is GameRoom and "is_hub" in child and child.is_hub:
				return child
	return null

func get_global_settings() -> Dictionary:
	return {
		"ai_assist_enabled": GlobalSettings.ai_assist_enabled,
		"openai_key": GlobalSettings.openai_key
	}

# Function to handle file save selection
func _on_FileSaveSelected(path: String) -> void:
	save_game(path)

# Function to handle file load selection
func _on_FileLoadSelected(path: String) -> void:
	load_game(path)

# Modified save_game function to use the provided path
func save_game(save_path: String) -> void:
	var game_state = get_game_state()
	var file = File.new()
	if file.open(save_path, File.WRITE) == OK:
		var json_string = JSON.print(game_state)
		var base64_string = Marshalls.utf8_to_base64(json_string)
		file.store_line(base64_string)
		file.close()
		print("Game saved successfully to ", save_path)
	else:
		print("Failed to save the game to ", save_path)

# Function to load the game state
func load_game(save_path: String) -> void:
	var file = File.new()
	if file.open(save_path, File.READ) == OK:
		var base64_string = file.get_line()
		var json_string = Marshalls.base64_to_utf8(base64_string)
		var game_state = JSON.parse(json_string).result
		set_game_state(game_state)
		file.close()
		print("Game loaded successfully.")
	else:
		print("Failed to load the game.")

func set_game_state(state: Dictionary) -> void:
	if state.has("player_state"):
		print("Setting Player State")
		player.set_player_state(state["player_state"])


	if state.has("rooms_state"):
		print("Setting Room State")
		set_rooms_state(state["rooms_state"])

	if state.has("global_settings"):
		print("Setting Global Settings")
		set_global_settings(state["global_settings"])

	if state.has("current_room"):
		print("Setting Current Room")
		var room_name = state["current_room"]
		var room = room_manager.find_node(room_name, true, false)
		if room and room is GameRoom:
			command_processor.change_room(room)
			_load_room_description_after_load(room)
			
func _load_room_description_after_load(room: GameRoom):
	var description = null
	description = room.get_full_description()
	game_info.create_response(Types.wrap_system_text("Game Restored!"))
	game_info.create_response(description)

# Function to set state of all rooms
func set_rooms_state(rooms_state: Dictionary) -> void:
	for room_path in rooms_state.keys():
		var room = get_node_or_null(room_path)
		if room and room is GameRoom:
			room.set_room_state(rooms_state[room_path], room_manager)

# Function to set global settings state
func set_global_settings(settings: Dictionary) -> void:
	if settings.has("ai_assist_enabled"):
		GlobalSettings.ai_assist_enabled = settings["ai_assist_enabled"]
	if settings.has("openai_key"):
		GlobalSettings.openai_key = settings["openai_key"]
