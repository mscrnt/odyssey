# CommandProcessor.gd

extends Node


signal room_changed(new_room)
signal room_updated(current_room)
signal inventory_changed

var current_room = null
var player = null
var room_manager = null

# warning-ignore:shadowed_variable
func initialize(starting_room, player) -> String:
	self.player = player
	return change_room(starting_room)


func process_command(input: String) -> String:
	input = input.strip_edges()  # Trim whitespace from the command
	var regex = RegEx.new()
	
	# Use regex for multi-word command processing
	var patterns = {
		"give": "^give (.+) to (.+)$",
		"use": "^use (.+) on (.+)$",
		"examine": "^examine (.+)$",
		"go": "^go (.+)$",
		"portal": "^portal (.+)$",
		"take": "^take (.+)$",
		"drop": "^drop (.+)$",
		"talk": "^talk to (.+)$"
	}

	for pattern in patterns.keys():
		regex.compile(patterns[pattern])
		var result = regex.search(input)
		if result:
			var command_details = result.get_strings()
			match pattern:
				"give":
					return give(command_details[1].strip_edges() + " to " + command_details[2].strip_edges())
				"use":
					return use(command_details[1].strip_edges() + " on " + command_details[2].strip_edges())
				"examine":
					return examine(command_details[1].strip_edges())
				"go":
					return go(command_details[1].strip_edges())
				"portal":
					return portal(command_details[1].strip_edges())
				"take":
					return take(command_details[1].strip_edges())
				"drop":
					return drop(command_details[1].strip_edges())
				"talk":
					return talk(command_details[1].strip_edges())

	# Single-word command handling
	var words = input.split(' ')
	if words.size() > 0:
		var first_word = words[0].to_lower()
		match first_word:
			"inventory":
				return inventory()
			"help":
				return help()
			"portals":
				return list_portals()
			"examine":
				return Types.wrap_system_text("Examine " + Types.wrap_item_text("what?"))
			"give":
				return Types.wrap_system_text("Give " + Types.wrap_item_text("what") + " to " + Types.wrap_npc_text("what?") + " Example: ") + "give " + Types.wrap_item_text("[item]") + " to " + Types.wrap_npc_text("[thing]") + "."
			"use":
				return Types.wrap_system_text("Use " + Types.wrap_item_text("what") + " to " + Types.wrap_npc_text("what?") + " Example: ") + "use " + Types.wrap_item_text("[item]") + " on " + Types.wrap_npc_text("[thing]") + "."
			"go":
				return Types.wrap_system_text("Go " + Types.wrap_location_text("where?"))
			"portal":
				return Types.wrap_system_text("Portal " + Types.wrap_location_text("where? \n" + list_portals()))
			"take":
				return Types.wrap_system_text("Take " + Types.wrap_item_text("what?"))
			"drop":
				return Types.wrap_system_text("Drop " + Types.wrap_item_text("what?"))
			"talk":
				return Types.wrap_system_text("Talk to " + Types.wrap_npc_text("whom?"))
			_:
				return Types.wrap_system_text("Unrecognized command or incorrect syntax.")
	else:
		return Types.wrap_system_text("Please enter a command.")




func go(location_name: String) -> String:
	# Normalize the input for comparison by converting it to lowercase
	location_name = location_name.to_lower()

	# Attempt to find an exit matching the normalized location name
	var found_exit = current_room.exits.get(location_name)
	if found_exit:
		if found_exit.is_other_room_locked(current_room):
			return Types.wrap_system_text("The way to the " + Types.wrap_location_text(location_name) + " is currently locked!")
		
		var change_response = change_room(found_exit.get_other_room(current_room))
		return PoolStringArray(["You go to " + Types.wrap_location_text(location_name) + "\n", change_response]).join("\n")
	else:
		return Types.wrap_system_text("This room has no exit to " + Types.wrap_location_text(location_name))

func list_portals() -> String:
	var fast_travel_locations = player.get_fast_travel_locations()
	var filtered_locations = []

	# Filter out the current room from the list of fast travel locations
	for location in fast_travel_locations:
		if current_room and location.to_lower() != current_room.room_name.to_lower():
			filtered_locations.append(location)

	var fast_travel_descriptions = PoolStringArray(filtered_locations).join("[/color] | [color=#BF55EC]")
	return "Portals: " + Types.wrap_portal_text(fast_travel_descriptions)


func portal(world_keyword: String) -> String:
	world_keyword = world_keyword.to_lower().strip_edges()

	# Check if the player is already in the requested location
	if current_room and current_room.room_name.to_lower() == world_keyword:
		return Types.wrap_system_text("You are already in " + Types.wrap_location_text(current_room.room_name) + ".")
		
	if world_keyword == "home":
		var home_room = room_manager.get_node("Home")  
		if home_room:
			return change_room(home_room)
		else:
			return Types.wrap_system_text("Home location not found.")


	var fast_travel_locations = player.get_fast_travel_locations()

	# Confirm if the player has access to this world's hub by checking their fast travel locations.
	var fast_travel_available = false
	for location_name in fast_travel_locations:
		if location_name.to_lower() == world_keyword:
			fast_travel_available = true
			break

	if not fast_travel_available:
		return Types.wrap_system_text("You do not have access to " + Types.wrap_location_text(world_keyword) + " for fast travel.")

	# Find the hub within this world by comparing in lowercase
	var world_node = null
	for i in range(room_manager.get_child_count()):
		var child = room_manager.get_child(i)
		if child.name.to_lower() == world_keyword:
			world_node = child
			break

	if not world_node:
		return Types.wrap_system_text("The world " + Types.wrap_location_text(world_keyword) + " does not exist.")

	for child in world_node.get_children():
		if "is_hub" in child and child.is_hub:
			return change_room(child)

	return Types.wrap_system_text("No hub found in the world of " + Types.wrap_location_text(world_keyword) + ".")


	
func take(second_word: String) -> String:
	for item in current_room.items:
		if second_word.to_lower() == item.item_name.to_lower():
			current_room.remove_item(item)
			player.take_item(item)
			emit_signal("inventory_changed")
			emit_signal("room_updated", current_room)
			return "You take the " + Types.wrap_item_text(second_word) + "."
			
	return Types.wrap_system_text("No item called " + Types.wrap_item_text(second_word) + " for you to take here.")
	
func give(command_details: String) -> String:
	var parts = command_details.split(" to ")
	if parts.size() != 2:
		return Types.wrap_system_text("Syntax error. Use 'give [item] to [npc]'.")

	var item_name = parts[0].strip_edges().to_lower()
	var npc_name = parts[1].strip_edges().to_lower()

	var item_to_give = null
	for item in player.inventory:
		if item.item_name.to_lower() == item_name:
			item_to_give = item
			break

	if not item_to_give:
		return Types.wrap_system_text("You don't have a " + Types.wrap_item_text(item_name) + " to give.")

	var npc_to_give_to = null
	for npc in current_room.npcs:
		if npc.npc_name.to_lower() == npc_name:
			npc_to_give_to = npc
			break

	if not npc_to_give_to:
		return Types.wrap_system_text("There's no one named " + Types.wrap_npc_text(npc_name) + " here to give anything to.")
	
	if npc_to_give_to.quest_item and npc_to_give_to.quest_item.item_name.to_lower() == item_name:
		npc_to_give_to.has_received_quest_item = true
		if npc_to_give_to.quest_reward != null:
			var reward = npc_to_give_to.quest_reward
			reward.room_2_is_locked = false  # Assuming 'reward' is the exit that needs to be unlocked
		player.drop_item(item_to_give)
		return "You give the " + Types.wrap_item_text(item_name) + " to " + Types.wrap_npc_text(npc_name) + "."
	
	return Types.wrap_system_text(npc_name.capitalize() + " doesn't need a " + item_name.capitalize() + ".")

	
func drop(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Drop what?")
	
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			current_room.add_item(item)
			player.drop_item(item)
			emit_signal("room_updated", current_room)
			emit_signal("inventory_changed")
			return "You dropped the " + Types.wrap_item_text(item.item_name) + "."
						
	return Types.wrap_system_text("You don't have a " + Types.wrap_item_text(second_word) + " to drop.")

func inventory() -> String:
	return player.get_inventory_list()

func use(command_details: String) -> String:
	var parts = command_details.split(" on ")
	if parts.size() != 2:
		return Types.wrap_system_text("Syntax error. Use 'use [item] on [object]'.")

	var item_name = parts[0].strip_edges().to_lower()
	var target_name = parts[1].strip_edges().to_lower()

	var item_to_use = null
	for item in player.inventory:
		if item.item_name.to_lower() == item_name:
			item_to_use = item
			break

	if not item_to_use:
		return Types.wrap_system_text("You don't have a " + Types.wrap_item_text(item_name) + " to use.")

	for exit in current_room.exits.values():
		if target_name == exit.room_2.room_name.to_lower() and item_to_use.use_value == exit:
			if exit.room_2_is_locked:
				exit.room_2_is_locked = false
				if item_to_use.is_single_use:
					player.drop_item(item_to_use)
					emit_signal('room_updated', current_room)
				emit_signal("inventory_changed")
				return "You used the " + Types.wrap_item_text(item_name) + " to unlock the door to " + Types.wrap_location_text(exit.room_2.room_name) + "."
			else:
				return Types.wrap_system_text("The " + Types.wrap_location_text(exit.room_2.room_name) + " is not locked.")

	return Types.wrap_system_text("There's nothing to use the " + Types.wrap_item_text(item_name) + " on here.")

func examine(target_name: String) -> String:
	target_name = target_name.to_lower()

	# Check if the target is an exit in the room
	for exit in current_room.exits.values():
		if exit and exit.room_2.room_name.to_lower() == target_name:
			return Types.wrap_location_text(exit.room_2.room_name) + ": " + exit.room_2.examine_text
		elif exit and exit.room_1 and exit.room_1.room_name.to_lower() == target_name:
			# This case will check if you can examine the room you're coming from, if necessary
			return Types.wrap_location_text(exit.room_1.room_name) + ": " + exit.room_1.examine_text

	# Check if the target is an item in the room
	for item in current_room.items:
		if item.item_name.to_lower() == target_name:
			return Types.wrap_item_text(item.item_name) + ": " + item.item_description

	# Check if the target is an NPC in the room
	for npc in current_room.npcs:
		if npc.npc_name.to_lower() == target_name:
			return Types.wrap_npc_text(npc.npc_name) + ": " + npc.npc_description

	return Types.wrap_system_text("There is no '" + target_name + "' to examine here.")

func talk(second_word: String) -> String:
	for npc in current_room.npcs:
		if npc.npc_name.to_lower() == second_word:
			var dialog = npc.post_quest_dialog if npc.has_received_quest_item else npc.initial_dialog
			return Types.wrap_npc_text(npc.npc_name + ": ") + Types.wrap_speech_text("\"" + dialog + "\"")
	
	return Types.wrap_system_text(Types.wrap_npc_text(second_word) + " is not in the area")

func help() -> String:
	return PoolStringArray([
		Types.wrap_system_text("Available commands:"),
		" - go " + Types.wrap_location_text("[location]") + ": " + Types.wrap_system_text("Example:") + " 'go " + Types.wrap_location_text("central avalonia") + "'",
		" - portal " + Types.wrap_portal_text("[world]") + ": " + Types.wrap_system_text("Example:") + " 'portal " + Types.wrap_portal_text("avalonia") + "'",
		" - examine " + Types.wrap_item_text("[item]") + ": " + Types.wrap_system_text("Example:") + " 'examine " + Types.wrap_item_text("door") + "'",
		" - take " + Types.wrap_item_text("[item]") + ": " + Types.wrap_system_text("Example:") + " 'take " + Types.wrap_item_text("enchanted sword") + "'",
		" - drop " + Types.wrap_item_text("[item]") + ": " + Types.wrap_system_text("Example:") + " 'drop " + Types.wrap_item_text("mystical shield") + "'",
		" - use " + Types.wrap_item_text("[item]") + " on " + Types.wrap_location_text("[object]") + ": " + Types.wrap_system_text("Example:") + " 'use " + Types.wrap_item_text("key") + " on " + Types.wrap_location_text("stone door") + "'",
		" - talk to " + Types.wrap_npc_text("[npc]") + ": " + Types.wrap_system_text("Example:") + " 'talk to " + Types.wrap_npc_text("merchant lorenzo") + "'",
		" - give " + Types.wrap_item_text("[item]") + " to " + Types.wrap_npc_text("[npc]") + ": " + Types.wrap_system_text("Example:") + " 'give " + Types.wrap_item_text("ruby") + " to " + Types.wrap_npc_text("queen") + "'",
		" - inventory " + Types.wrap_system_text('Displays contents of your inventory'),
		" - portals " + Types.wrap_system_text('Displays available fast travel locations'),
		" - help " + Types.wrap_system_text('Displays this message ;)'),
	]).join("\n")



func change_room(new_room: GameRoom) -> String:
	current_room = new_room
	CurrentRoom.current_room = new_room
	emit_signal("room_changed", new_room)
	return new_room.get_full_description()
