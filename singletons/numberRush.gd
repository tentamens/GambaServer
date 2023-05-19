extends Node

var numberRushState = {}


func numberStateSubtract(clientID):
	if numberRushState.has(clientID):
		numberRushState.erase(clientID)

func loadNumberScore(clientID):
	if numberRushState.has(clientID):
		return numberRushState[clientID]

func addNumberScore(clientID, numbers):
	numberRushState[clientID] = numbers

func checkIfCurrentlyActive(clientID):
	if numberRushState.has(clientID):
		return false
	return true
