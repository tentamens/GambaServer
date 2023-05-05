extends Node

var mineState = {}

var mineWinningRates = [2, 1.2, 0]





func mineStateSubtract(mineID):
	if mineState.has(mineID):
		mineState.erase(mineID)

func loadMineScore(mineID):
	if mineState.has(mineID):
		return mineState[mineID]

func addMineScore(mineID, numbers):
	mineState[mineID] = numbers

func checkIfCurrentlyActive(mineID):
	if mineState.has(mineID):
		return true
	return false
