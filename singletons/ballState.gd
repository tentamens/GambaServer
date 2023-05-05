extends Node

var ballState = {}



func ballStateSubtract(ballID):
	if ballState.has(ballID):
		ballState.erase(ballID)


func loadBallScore(ballID):
	return ballState[ballID]

func addBallScore(ballID, score):
	ballState[ballID] = score

