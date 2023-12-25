extends Node


var inventory: Array = []
var fast_travel_locations: Dictionary = {}
var portals: Dictionary = {}

func add_fast_travel_location(world_name: String, location: GameRoom):
	fast_travel_locations[world_name] = location

func take_item(item: Item):
	inventory.append(item)
	
func drop_item(item: Item):
	inventory.erase(item)

func get_inventory_list() -> String:
	if inventory.size() == 0:
		return Types.wrap_system_text("You aren't currently holding anything!")
		
	var item_string = ""
	for item in inventory:
		if item != inventory[inventory.size() - 1]:
			item_string += Types.wrap_item_text(item.item_name) + " | "
		else:
			item_string += Types.wrap_item_text(item.item_name)
	return Types.wrap_system_text("Inventory: ") + item_string + "\n"

func get_fast_travel_locations() -> Array:
	# This will return an array of world names.
	return fast_travel_locations.keys()

func connect_portal(world_name: String, room: GameRoom):
	# Check if the world name is already in the fast travel locations
	if fast_travel_locations.has(world_name):
		print("Portal to world '%s' is already connected." % world_name)
		return
	
	# Create the portal and add the location
	var portal = FastTravel.new()
	portal.room_1 = self
	portal.room_2 = room
	portals[world_name] = portal  # Use world name as the key

	
	add_fast_travel_location(world_name, room)
