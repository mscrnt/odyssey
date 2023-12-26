# Game.gd

extends Control

onready var game_info = $Background/MarginContainer/Columns/GameRows/GameInfo
onready var command_processor = $CommandProcessor
onready var room_manager = $RoomManager
onready var player = $Player
onready var info_rows = $Background/MarginContainer/Columns/InfoRows
onready var inventory_panel = $Background/MarginContainer/Columns/InfoRows/InventoryPanel
onready var location_info_scene = preload("res://scenes/LocationInfo.tscn")
onready var inventory_info_scene = preload("res://scenes/InventoryInfo.tscn")
onready var info_label = $Background/MarginContainer/Columns/InfoRows/InventoryLabel/InfoLabel


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
	info_rows.player = player  # Ensure InfoRows has reference to the player

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
	room_manager.initialize(player)

	var starting_room_response = command_processor.initialize(room_manager.get_child(0), player)
	game_info.create_response(Types.wrap_system_text("Welcome to Odyssey! You are currently in your Home. A recent email from your friend Athena has caught your attention. She urgently needs to meet with you in Avalonia. To embark on this adventure, use the 'portal' command followed by the destination to fast travel. For instance, type 'portal avalonia' to travel there. Remember, you can view a list of available commands anytime by typing 'help'. Good luck on your journey!"))
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
