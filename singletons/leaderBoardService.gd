extends Node

var sortedArray : Array = []

var compressedLeaderBoard : PackedByteArray = PackedByteArray()
var payoutTime = 9090090906


func timer():
	await get_tree().create_timer(60.0).timeout
	EndDataCheck()
	timer()



func _ready():
	sortedArray.sort_custom(sort_ascending)
	loadLeaderBoard()
	timer()

func storeLeaderBoard():
	var file = FileAccess.open("user://LeaderBoard.name", FileAccess.WRITE)
	file.store_var(sortedArray)


func loadLeaderBoard():
	if FileAccess.file_exists("user://LeaderBoard.name"):
		var file = FileAccess.open("user://LeaderBoard.name", FileAccess.READ)
		sortedArray = file.get_var()
		sortedArray.sort_custom(sort_ascending)
		print(sortedArray)
		return
	sortedArray = []


func addNewMember(username, score, UID):
	sortedArray.insert(sortedArray.bsearch([UID, username]), [score, username, UID])
	sortedArray.sort_custom(sort_ascending)
	storeLeaderBoard()

func sort_ascending(a, b):
	if a[0] > b[0]:
		return true
	return false

func findScorePlacement(score, username):
	return sortedArray.bsearch([score, username])
	


func EndDataCheck():
	if Time.get_unix_time_from_system() > payoutTime:
		UpdateTime()
		sortedArray.sort_custom(sort_ascending)
		JackPot.addNewWinner(sortedArray[0])
		sortedArray = []
		storeLeaderBoard()



func UpdateTime():
	payoutTime += 60*60*24*2


