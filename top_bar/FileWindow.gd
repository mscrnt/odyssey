# FileWindow.gd

extends FileDialog

# Signal declarations for custom signals if needed
signal file_save_selected(path)
signal file_load_selected(path)

func _ready() -> void:
	# Set up the dialog for saving or loading
	connect("file_selected", self, "_on_File_selected")
	connect("dir_selected", self, "_on_Dir_selected")
	mode = MODE_SAVE_FILE  # Default mode
	window_title = "Select File to Save"  # Default title
	current_path = "user://"  # Default path

# Function to configure the dialog to save mode
func configure_for_save() -> void:
	mode = MODE_SAVE_FILE
	window_title = "Select File to Save"
	current_path = "user://"  # or another appropriate default path
	popup_centered(Vector2(600, 400))  # Open the dialog centered with the given size

# Function to configure the dialog to load mode
func configure_for_load() -> void:
	mode = MODE_OPEN_FILE
	window_title = "Select File to Load"
	current_path = "user://"  # or another appropriate default path
	popup_centered(Vector2(600, 400))  # Open the dialog centered with the given size

func _on_File_selected(path: String) -> void:
	if mode == MODE_SAVE_FILE:
		emit_signal("file_save_selected", path)
	elif mode == MODE_OPEN_FILE:
		emit_signal("file_load_selected", path)

func _on_Dir_selected(path: String) -> void:
	# Handle directory selection if needed
	pass
