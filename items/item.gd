extends Resource
class_name Item

export (String) var item_name := "Item Name"
export (Types.ItemTypes) var item_type := Types.ItemTypes.KEY
export (String) var item_description := "Item Description"


func initialize(item_name: String, item_type: int, item_description):
	self.item_name = item_name
	self.item_type = item_type
	self.item_description = item_description
