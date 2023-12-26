# InfoRows.gd
extends VBoxContainer

var player = null

var location_info_scene
var inventory_info_scene

# Dictionary to store instances
var content_panels = {}

signal dropdown_selected(type)


onready var dropdown_menu = $DropDownMenu/OptionButton
onready var content_label = $InventoryLabel/InfoLabel
onready var content_container = $InventoryPanel/MarginContainer

func initialize_display(default_type: String, loc_info_scene, inv_info_scene):
	location_info_scene = loc_info_scene
	inventory_info_scene = inv_info_scene
	_load_content_panels()
	change_display(default_type)

func _load_content_panels():
	content_panels["Location Info"] = location_info_scene.instance()
	content_panels["Inventory"] = inventory_info_scene.instance()


func change_display(type: String):
	content_label.text = type  # Update label
	for key in content_panels.keys():
		content_panels[key].visible = false
	content_panels[type].visible = true
	if type == "Inventory":
		_update_inventory_display()

func _clear_content():
	for child in content_container.get_children():
		content_container.remove_child(child)
		child.queue_free()

func _on_dropdown_item_selected(index: int):
	var selected_option = dropdown_menu.get_item_text(index)
	emit_signal("dropdown_selected", selected_option)
	change_display(selected_option)

func update_room_info(new_room):
	if content_panels["Location Info"]:
		content_panels["Location Info"].update_room_info(new_room)

func _update_inventory_display():
	if content_panels["Inventory"] and player:
		var inventory_items = player.get_inventory_list()
		content_panels["Inventory"].update_inventory_display(inventory_items)
