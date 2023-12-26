# InventoryInfo.gd

extends VBoxContainer

onready var scroll = $InventoryPanel/MarginContainer/Scroll
onready var scrollbar = scroll.get_v_scrollbar()


onready var inventory_label = $InventoryPanel/MarginContainer/Scroll/Rows/ListArea/InventoryList


# This function will be called to update the inventory display
func update_inventory_display(inventory_items: String):
	if inventory_items.strip_edges() == "":
		# If the inventory is empty, display a message saying so
		inventory_label.bbcode_text = "Inventory is empty."
	else:
		# Otherwise, display the inventory items
		inventory_label.bbcode_text = inventory_items



func _handle_scrollbar_change():
	scrollbar.value = 0
