extends WindowDialog


onready var how_to_play_text = $MarginContainer/VBoxContainer/Scroll/Content/MarginContainer/HowToPlayText
onready var close_button = $MarginContainer/VBoxContainer/BottomButton/CloseButton

onready var scroll = $MarginContainer/VBoxContainer/Scroll
onready var scrollbar = scroll.get_v_scrollbar()

func _ready():
	close_button.connect("pressed", self, "_on_CloseButton_pressed")
	# Set the BBCode text of the RichTextLabel node when the dialog is ready.
	how_to_play_text.bbcode_text = _get_how_to_play_bbcode()
	_handle_scrollbar_change()

func _get_how_to_play_bbcode() -> String:
	return """
	Welcome to [b]Odyssey VR[/b]!
	This guide will help you understand how to interact with the world using various commands.

	[b]Basic Commands[/b]:
	- [color=#f7c07c]go [location][/color]: Move to a different room. Example: go central avalonia
	- [color=#BF55EC]portal [world][/color]: Use a portal to fast travel. Example: portal avalonia
	- [color=#94b9ff]examine [item][/color]: Get details about an item. Example: examine door
	- [color=#94b9ff]take [item][/color]: Pick up an item. Example: take enchanted sword
	- [color=#94b9ff]drop [item][/color]: Leave an item behind. Example: drop mystical shield
	- [color=#94b9ff]use [item] on [object][/color]: Use an item on something. Example: use key on stone door
	- [color=#ff9a94]talk to [npc][/color]: Speak with a character. Example: talk to merchant lorenzo
	- [color=#94b9ff]give [item] to [npc][/color]: Give an item to a character. Example: give ruby to queen
	- inventory: View the items you are carrying.
	- portals: See a list of places you can travel to instantly.
	- help: Display a list of all these commands.

	[b]Interaction with NPCs[/b]:
	Interact with characters by talking to them, giving them items, or helping them with their quests. Pay attention to their dialogue as it may contain clues or important information about your journey.

	[b]Managing Inventory[/b]:
	Your inventory holds items you've collected. Use the 'take' command to pick items up and 'drop' to leave them. Some items can be used to unlock paths or solve puzzles.

	[b]Exploring Locations[/b]:
	Each location in Odyssey VR is unique and may contain hidden secrets. Use the 'examine' command to look closer at your surroundings and discover what they might hide.

	Remember, your choices and actions shape your path through the world of Odyssey VR. Explore, interact, and unravel the mysteries that await!

	Good luck on your adventure, traveler!
	"""

func _on_CloseButton_pressed():
	hide() 

func _handle_scrollbar_change():
	scrollbar.value = 0
