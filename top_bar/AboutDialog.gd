extends WindowDialog


onready var about_text = $MarginContainer/VBoxContainer/Scroll/Content/MarginContainer/AboutText
onready var close_button = $MarginContainer/VBoxContainer/BottomButton/CloseButton

onready var scroll = $MarginContainer/VBoxContainer/Scroll
onready var scrollbar = scroll.get_v_scrollbar()

func _ready():
	close_button.connect("pressed", self, "_on_CloseButton_pressed")
	# Set the BBCode text of the RichTextLabel node when the dialog is ready.
	about_text.bbcode_text = _get_how_to_play_bbcode()
	_handle_scrollbar_change()

func _get_how_to_play_bbcode() -> String:
	return """
	This is just a placeholder until I can spend more time on this. 
	"""

func _on_CloseButton_pressed():
	hide() 

func _handle_scrollbar_change():
	scrollbar.value = 0
