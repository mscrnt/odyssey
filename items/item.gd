extends Resource
class_name Item

export (String) var item_name := "Item Name"
export (String) var display_name := "Display Name"
export (Types.ItemTypes) var item_type := Types.ItemTypes.KEY
export (String, MULTILINE) var item_description := "Item Description"
export (String, MULTILINE) var examine_text = "This is text that appears when you examine this item."

var use_value = null


func initialize(item_name: String, item_type: int, item_description):
	self.item_name = item_name
	self.item_type = item_type
	self.item_description = item_description
