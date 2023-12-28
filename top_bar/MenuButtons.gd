# MenuButtons.gd

extends HBoxContainer

var can_exit_game = false

onready var settings_window_scene = preload("res://SettingsDialog.tscn")
var settings_window_instance: WindowDialog = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setup File Menu
	var file_menu = $File.get_popup()
	file_menu.add_item("New Game", 0)
	file_menu.add_item("Save", 1)
	file_menu.add_item("Load", 2)
	
	# Setup Settings Menu
	var settings_menu = $Settings.get_popup()
	settings_menu.add_item("Edit Settings", 3)
	
	# Setup Help Menu
	var help_menu = $Help.get_popup()
	help_menu.add_item("Commands", 4)
	help_menu.add_item("About", 5)
	
	# Add and initially disable the Exit button
	var exit_button = $Exit
	exit_button.disabled = true  # Disable the button
	
	# Connect signals for menu actions
	file_menu.connect("id_pressed", self, "_on_FileMenu_item_selected")
	settings_menu.connect("id_pressed", self, "_on_SettingsMenu_item_selected")
	help_menu.connect("id_pressed", self, "_on_HelpMenu_item_selected")
	exit_button.connect("pressed", self, "_on_Exit_button_pressed")

# Callback functions for menu item selections
func _on_FileMenu_item_selected(id):
	match id:
		0:
			print("New Game selected")
			# Handle new game action here
		1:
			print("Save selected")
			# Handle save action here
		2:
			print("Load selected")
			# Handle load action here

func _on_SettingsMenu_item_selected(id):
	if id == 3:  # Check if the 'Edit Settings' option was selected.
		if not settings_window_instance:
			settings_window_instance = settings_window_scene.instance() as WindowDialog
			get_tree().root.add_child(settings_window_instance)  # Add to the scene tree.
		settings_window_instance.popup_centered()  # Show the settings window.

# Function to instantiate and show the settings window.
func _show_settings_window():
	if not settings_window_instance:
		# Assuming 'SettingsWindow' is the name of the WindowDialog node in the scene.
		settings_window_instance = settings_window_scene.instance().get_node("SettingsWindow")
		get_tree().root.add_child(settings_window_instance)
	settings_window_instance.popup()

func _on_HelpMenu_item_selected(id):
	match id:
		4:
			print("Commands selected")
			# Handle commands action here
		5:
			print("About selected")
			# Handle about action here

# Callback function for exit button pressed
func _on_Exit_button_pressed():
	if can_exit_game:
		print("Exiting game...")
		get_tree().quit()  # Exit the game
	else:
		print("Exit currently disabled")

# Function to enable the exit button when called
func enable_exit():
	can_exit_game = true
	$Exit.disabled = false  # Enable the button
