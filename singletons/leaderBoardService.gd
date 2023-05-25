extends Node

var sortedArray : Array = [[2321, "Florian"], [2100, "Flou"], [5291, "Mühlhans"]]

var compressedLeaderBoard : PackedByteArray = PackedByteArray()

func _ready():
	sortedArray.sort_custom(sort_ascending)

func addNewMember(username, score, UID):
	sortedArray.insert(sortedArray.bsearch([UID, username]), [score, username, UID])
	sortedArray.sort_custom(sort_ascending)
	print(sortedArray)

func sort_ascending(a, b):
	if a[0] > b[0]:
		return true
	return false

func findScorePlacement(score, username):
	return sortedArray.bsearch([score, username])
	


