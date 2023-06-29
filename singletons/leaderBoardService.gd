extends Node

var sortedArray = []

var compressedLeaderBoard : PackedByteArray = PackedByteArray()
var payoutTime = 9090090906

var publicLB = []


func timer():
	await get_tree().create_timer(60.0).timeout
	EndDataCheck()
	timer()


var test = [1,2]

func _ready():
	sortedArray.sort_custom(sort_ascending)
	storeLeaderBoard()
	loadLeaderBoard()
	timer()


func storeLeaderBoard():
	# /data/LeaderBoard.name
	var file = FileAccess.open("user://LeaderBoard.name", FileAccess.WRITE)
	file.store_var(sortedArray)


func loadLeaderBoard():
	if FileAccess.file_exists("user://LeaderBoard.name"):
		var file = FileAccess.open("user://LeaderBoard.name", FileAccess.READ)
		sortedArray = file.get_var()
		sortedArray.sort_custom(sort_ascending)
		print(sortedArray)
		if sortedArray.size() < 23:
			updatePublicLB(sortedArray.slice(0, 23), null)
			return
		updatePublicLB(sortedArray, null)
		return
	sortedArray = []


func addNewMember(username, score, UID):

	
	
	if sortedArray.bsearch([UID]) == sortedArray.size():
		sortedArray.append([score, username, UID])
		storeLeaderBoard()
		if sortedArray.size() < 23:
			updatePublicLB(sortedArray.slice(0, 23), sortedArray.bsearch([UID]))
		return
	
	var pos = sortedArray.bsearch([UID])
	
	sortedArray[pos] = [score, username, UID]
	sortedArray.sort_custom(sort_ascending)
	
	if pos < 23:
		updatePublicLB(sortedArray.slice(0, 23), pos)
	
	storeLeaderBoard()


func updatePublicLB(lb, pos):
	if pos == null:
		for i in lb:
			publicLB.append([i[0], i[1]])
		print(publicLB)
		return
	
	if publicLB.size() <= pos:
		print(lb)
		pos -= 1
		publicLB.append([lb[pos][0], lb[pos][1]])
		return
	
	publicLB[pos] = lb[pos]
	


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


