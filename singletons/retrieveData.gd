extends Node

var path = "res://Data/playerState.json"

var playersScores = {}

func _ready():

	pass
	


func playerStateSubtract(clientID):
	if playersScores.has(clientID):
		playersScores.erase(clientID)


func playerStateAdd(clientID, content):
	
	playersScores[clientID] = content
	

func loadData(fileLocation):
	var file = FileAccess.open(fileLocation, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content


func loadPlayerScore(clientID):
	return playersScores[clientID]

func loadPlayerScoreSubtractBet(clientID, currentBet):
	playersScores[clientID] = playersScores[clientID] - currentBet 



