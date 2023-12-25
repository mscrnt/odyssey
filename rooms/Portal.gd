extends Resource
class_name FastTravel


var room_1 = null


var room_2 = null


func get_other_room(current_room):
	if current_room == room_1:
		return room_2
	elif current_room == room_2:
		return room_1
	else:
		printerr("The room you tried to find is not connected to this exit!")
		return null
