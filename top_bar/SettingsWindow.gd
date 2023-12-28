extends WindowDialog

# Make sure to use the correct node paths according to your scene structure.
onready var ai_assist_checkbox = $PanelContainer/MarginContainer/VBoxContainer/Content/Row_1/AIAssistCheckBox
onready var openai_key_textbox = $PanelContainer/MarginContainer/VBoxContainer/Content/Row_1/OpenAIKeyTextBox
onready var save_button = $PanelContainer/MarginContainer/VBoxContainer/BottomButtons/SaveButton
onready var cancel_button = $PanelContainer/MarginContainer/VBoxContainer/BottomButtons/CancelButton

func _ready():
	ai_assist_checkbox.pressed = GlobalSettings.ai_assist_enabled
	openai_key_textbox.text = GlobalSettings.openai_key
	openai_key_textbox.editable = ai_assist_checkbox.pressed
	# Connect signals
	save_button.connect("pressed", self, "_on_SaveButton_pressed")
	cancel_button.connect("pressed", self, "_on_CancelButton_pressed")
	ai_assist_checkbox.connect("toggled", self, "_on_AIAssistCheckBox_toggled")

func _on_AIAssistCheckBox_toggled(is_enabled: bool):
	openai_key_textbox.editable = is_enabled

func _on_SaveButton_pressed():
	GlobalSettings.ai_assist_enabled = ai_assist_checkbox.pressed
	GlobalSettings.openai_key = openai_key_textbox.text
	print("Settings saved with AI Assist:", GlobalSettings.ai_assist_enabled, " and OpenAI Key:", GlobalSettings.openai_key)
	hide()  # Close the dialog after saving

func _on_CancelButton_pressed():
	hide()  # Close the dialog without saving
