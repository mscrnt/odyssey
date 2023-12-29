# Player.gd

extends Node

onready var room_manager = null
onready var game_node = get_node("/root/Game")

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
			item_string += Types.wrap_item_text(item.display_name) + " | "
		else:
			item_string += Types.wrap_item_text(item.display_name)
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

func get_player_state() -> Dictionary:
	var inventory_data = []
	for item in inventory:
		inventory_data.append(item.get_item_state())

	var portals_data = []
	for world_name in portals.keys():
		var portal = portals[world_name]
		if portal.room_2:
			portals_data.append({
				"world_name": world_name,
				"room_2_name": portal.room_2.room_name
			})

	return {
		"inventory": inventory_data,
		"fast_travel_locations": fast_travel_locations.keys(),
		"portals": portals_data
	}

func set_player_state(state: Dictionary) -> void:
	if state.has("inventory"):
		inventory.clear()
		for item_data in state["inventory"]:
			var item = create_or_fetch_item(item_data)
			inventory.append(item)

	if state.has("portals"):
		portals.clear()
		for portal_data in state["portals"]:
			var world_name = portal_data["world_name"]
			var hub = game_node.get_hub_from_world(world_name)
			if hub:
				connect_portal(world_name, hub)
			else:
				printerr("Failed to restore portal for ", world_name)

	if state.has("fast_travel_locations"):
		fast_travel_locations.clear()
		for world_name in state["fast_travel_locations"]:
			var hub = game_node.get_hub_from_world(world_name)
			if hub:
				fast_travel_locations[world_name] = hub
			else:
				printerr("Could not find hub in world: " + world_name)


func create_or_fetch_item(item_data: Dictionary) -> Item:
	var item_name = item_data["item_name"]
	var item

	# Check if the item already exists in the inventory
	for existing_item in inventory:
		if existing_item.item_name == item_name:
			item = existing_item
			break

	# If the item does not exist, create a new one
	if item == null:
		# Use the instance of room_manager to load the item
		item = room_manager.load_item(item_name) as Item
		if item:
			item.set_item_state(item_data)
		else:
			printerr("Failed to load item: " + item_name)

	return item
