extends Node

var current_room = null
var player = null

func initialize(starting_room, player) -> String:
	self.player = player
	return change_room(starting_room)


func process_command(input: String) -> String:
	var words = input.split(' ', false)
	if words.size() == 0:
		return Types.wrap_system_text("Error: no words were parsed.")

	var first_word = words[0].to_lower()
	var second_word = ""
	if words.size() > 1:
		second_word = words[1].to_lower()
		
	match first_word:
		"go":
			return go(second_word)
		"take":
			return take(second_word)
		"give":
			return give(second_word)
		"drop":
			return drop(second_word)
		"inventory":
			return inventory()
		"use":
			return use(second_word)
		"talk":
			return talk(second_word)
		"help":
			return help()
		_:
			return Types.wrap_system_text("Unrecognized command - please try again.")
			


func go(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Go where?")
	
	if current_room.exits.keys().has(second_word):
		var exit = current_room.exits[second_word]
		if exit.is_other_room_locked(current_room):
			return Types.wrap_system_text("The way to the " + Types.wrap_location_text(second_word) + " is currently locked!")
			
		var change_response = change_room(exit.get_other_room(current_room))
		return PoolStringArray(["You go to " + Types.wrap_location_text(second_word) + "\n", change_response]).join("\n")
	else:
		return Types.wrap_system_text("This room has no exit to " + Types.wrap_location_text(second_word))
	
func take(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Take what?")
		
	for item in current_room.items:
		if second_word.to_lower() == item.item_name.to_lower():
			current_room.remove_item(item)
			player.take_item(item)
			return "You take the " + Types.wrap_item_text(second_word) + "."
			
	return Types.wrap_system_text("No item called " + Types.wrap_item_text(second_word) + " for you to take here.")
	
func give(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Give what?")

	var has_item := false
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			has_item = true
			
	if not has_item:
		return Types.wrap_system_text("You don't have the item, " + Types.wrap_item_text(second_word) + ", to give!")
	
	for npc in current_room.npcs:
		if npc.quest_item != null and second_word.to_lower() == npc.quest_item.item_name.to_lower():
			npc.has_received_quest_item = true
			if npc.quest_reward != null:
				var reward = npc.quest_reward
				if "room_2_is_locked" in reward:
					reward.room_2_is_locked = false
				else:
					printerr("Warning - tried to have a quest reward type that isn't in the game!")
			player.drop_item(second_word)
			return "You give the " + Types.wrap_item_text(second_word) + " to " + Types.wrap_npc_text(npc.npc_name)
	
	return Types.wrap_system_text("Nobody here wants the " + Types.wrap_item_text(second_word) + ".")
	
func drop(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Drop what?")
	
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			current_room.add_item(item)
			player.drop_item(item)
			return "You dropped the " + Types.wrap_item_text(item.item_name) + "."
						
	return Types.wrap_system_text("You don't have a " + Types.wrap_item_text(second_word) + " to drop.")

func inventory() -> String:
	return player.get_inventory_list()

func use(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Use what?")
	
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			match item.item_type:
				Types.ItemTypes.KEY:
					for exit in current_room.exits.values():
						if exit == item.use_value:
							exit.room_2_is_locked = false
							player.drop_item(item)
							return "You used the " + Types.wrap_item_text(item.item_name) + " to unlock the door to " + Types.wrap_location_text(exit.room_2.room_name)
					return Types.wrap_system_text("That " + Types.wrap_item_text(item.item_name) + " does not unlock any doors in this room!")
				_:
					return Types.wrap_system_text("Error - tried to use an item with an invalid type!")
			
	return Types.wrap_system_text("You don't have a " + Types.wrap_item_text(second_word) + " to use!")

func talk(second_word: String) -> String:
	if second_word == "":
		return Types.wrap_system_text("Talk to who?")
	
	for npc in current_room.npcs:
		if npc.npc_name.to_lower() == second_word:
			var dialog = npc.post_quest_dialog if npc.has_received_quest_item else npc.initial_dialog
			return Types.wrap_npc_text(npc.npc_name + ": ") + Types.wrap_speech_text("\"" + dialog + "\"")
	
	return Types.wrap_system_text(Types.wrap_npc_text(second_word) + " is not in the area")

func help() -> String:
	return Types.wrap_system_text(PoolStringArray([
		"You can use these commands: ",
		" go " + Types.wrap_location_text("[location]"),
		" take " + Types.wrap_item_text("[item]"),
		" drop " + Types.wrap_item_text("[item]"),
		" use " + Types.wrap_item_text("[item]"),
		" talk " + Types.wrap_npc_text("[npc]"),
		" give " + Types.wrap_item_text("[item]"),
		" inventory",
		" help"
	]).join("\n"))

func change_room(new_room: GameRoom) -> String:
	current_room = new_room
	return new_room.get_full_description()
