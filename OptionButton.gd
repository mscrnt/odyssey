# OptionButton.gd

extends OptionButton


# Add items to drop down menu in gdscript
func _ready():
	var items = ["Location Info", "Inventory"]
	for item in items:
		add_item(item, items.find(item))
