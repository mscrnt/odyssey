extends Node

var current_room = null
var player = null

func initialize(starting_room, player) -> String:
	self.player = player
	return change_room(starting_room)


func process_command(input: String) -> String:
	var words = input.split(' ', false)
	if words.size() == 0:
		return "Error: no words were parsed."

	var first_word = words[0].to_lower()
	var second_word = ""
	if words.size() > 1:
		second_word = words[1].to_lower()
		
	match first_word:
		"go":
			return go(second_word)
		"take":
			return take(second_word)
		"drop":
			return drop(second_word)
		"inventory":
			return inventory()
		"use":
			return use(second_word)
		"help":
			return help()
		_:
			return "Unrecognized command - please try again."
			

func go(second_word: String) -> String:
	if second_word == "":
		return "Go where?"
	
	if current_room.exits.keys().has(second_word):
		var exit = current_room.exits[second_word]
		if exit.is_other_room_locked(current_room):
			return "The way to the %s is currently locked!" % second_word
			
		var change_response = change_room(exit.get_other_room(current_room))
		return PoolStringArray(["You go %s" % second_word + "\n", change_response]).join("\n")
	else:
		return "This room has no exit in that direction!"
	
func take(second_word: String) -> String:
	if second_word == "":
		return "Take what?"
		
	for item in current_room.items:
		if second_word.to_lower() == item.item_name.to_lower():
			current_room.remove_item(item)
			player.take_item(item)
			return "You take the " + item.item_name
			
	return "No item called '" + second_word + "' for you to take here."
	
func drop(second_word: String) -> String:
	if second_word == "":
		return "Drop what?"
	
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			current_room.add_item(item)
			player.drop_item(item)
			return "You drop the " + item.item_name
			
	return "You don't have that item to drop."

func inventory() -> String:
	return player.get_inventory_list()

func use(second_word: String) -> String:
	if second_word == "":
		return "Use what?"
	
	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			match item.item_type:
				Types.ItemTypes.KEY:
					for exit in current_room.exits.values():
						if exit == item.use_value:
							exit.room_2_is_locked = false
							player.drop_item(item)
							return "You used %s to unlock a door to %s" % [item.item_name, exit.room_2.room_name]
					return "That item does not unlock any doors in this room!"
				_:
					return "Error - tried to use an item with an invalid type!"
			
	return "You don't have that item to use."


func help() -> String:
	return "You can use these commands: go [Location], take [item], drop [item], inventory, help"

func change_room(new_room: GameRoom) -> String:
	current_room = new_room
	return new_room.get_full_description()
