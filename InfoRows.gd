extends VBoxContainer

onready var scroll = $InventoryPanel/MarginContainer/Scroll
onready var scrollbar = scroll.get_v_scrollbar()

onready var info_label = $InventoryLabel/InfoLabel
onready var room_name = $InventoryPanel/MarginContainer/Scroll/Rows/TitleSection/RoomNameLabel
onready var room_description = $InventoryPanel/MarginContainer/Scroll/Rows/RoomDescLabel
onready var exit_label = $InventoryPanel/MarginContainer/Scroll/Rows/ListArea/ExitLabel
onready var npc_label = $InventoryPanel/MarginContainer/Scroll/Rows/ListArea/NpcLabel
onready var item_label = $InventoryPanel/MarginContainer/Scroll/Rows/ListArea/ItemLabel

func handle_room_changed(new_room):
	_handle_scrollbar_change()
	room_name.text = new_room.room_name
	room_description.text = new_room.room_description
	
	exit_label.bbcode_text = new_room.get_exit_description()
	npc_label.bbcode_text = new_room.get_npc_description()
	item_label.bbcode_text = new_room.get_item_description()
	
func handle_room_updated(current_room):
	handle_room_changed(current_room)

func _handle_scrollbar_change():
	scrollbar.value = 0

