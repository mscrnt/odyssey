extends OptionButton


# Add items to drop down menu in gdscript
func _ready():
	var items = ["Inventory", "Notes", "Quest Log", "Emails", "Fast Travel"]
	for item in items:
		add_item(item, items.find(item))
