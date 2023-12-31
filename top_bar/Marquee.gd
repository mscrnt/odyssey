# Marquee.gd
extends RichTextLabel

var message: String = "Welcome to Odyssey!"
var current_display: String = ""
var display_speed: float = 0.04  # Time in seconds before the next character is added
var index: int = 0
var timer: Timer

func _ready():
	# Create a new Timer node and configure it
	timer = Timer.new()
	timer.set_wait_time(display_speed)
	timer.set_one_shot(false)  # The timer is not one-shot because we'll manually stop it later
	add_child(timer)
	
	# Connect the timer's timeout signal to a function on this script
	timer.connect("timeout", self, "_on_Timer_timeout")
	
	# Start the timer
	timer.start()
	
	# Initialize the display
	set_text("")

func set_text(text: String):
	# Use bbcode to center the text
	bbcode_text = "[center]" + text + "[/center]"

func _on_Timer_timeout():
	if index < message.length():
		# Add the next character to the display
		current_display += message[index]
		index += 1
		set_text(current_display)
		timer.start()  # Restart the timer for the next character
	else:
		# After the full message is displayed, stop the timer to prevent repetition
		timer.stop()
