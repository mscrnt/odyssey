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
	# Set the current path to the user's Documents folder
	current_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/OdysseyGame"
	# Create the directory if it does not exist
	var dir := Directory.new()
	if not dir.dir_exists(current_path):
		dir.make_dir_recursive(current_path)
	# Set the file dialog to show only files with the custom extension
	filters = ["*.ods ; Odyssey Save Files"]



# Function to configure the dialog to save mode
func configure_for_save():
	mode = MODE_SAVE_FILE
	access = ACCESS_FILESYSTEM
	window_title = "Select File to Save"
	var user_documents_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	current_dir = user_documents_dir
	popup_centered(Vector2(600, 400))

func configure_for_load():
	mode = MODE_OPEN_FILE
	access = ACCESS_FILESYSTEM
	window_title = "Select File to Load"
	var user_documents_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	current_dir = user_documents_dir
	popup_centered(Vector2(600, 400))

func _on_File_selected(path: String) -> void:
	if mode == MODE_SAVE_FILE:
		# Append the custom extension if not present
		if not path.ends_with(".ods"):
			path += ".ods"
		emit_signal("file_save_selected", path)
	elif mode == MODE_OPEN_FILE:
		emit_signal("file_load_selected", path)

func _on_Dir_selected(path: String) -> void:
	# Handle directory selection if needed
	pass
