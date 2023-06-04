extends Node

var winners = {3437449764344: [69420, "Tentamens", [10, "4201-2345-6789-4206", "4/20", 420]]}

var winnerBoard = {"Äkwav": 10}

# format Amount Pin expiration data, security code 
var currentRewards = [[10, "1234-5678-9101-1121", "4/20", 420]]

func _physics_process(delta):
	if currentRewards.is_empty():
		print(" !!!! THERE ARE NO MORE REWARDS !!!!!")


func checkUIDforWinner(UID):
	if winners.has(UID):
		return winners[UID]
	return null



func addNewWinner(user:Array):
	if winners.has(user[2]):
		winners[user[2]] = winners[user[2]] + [user[0], user[1], [currentRewards[0]]]
		winnerBoard[user[2]] = [user[1], currentRewards[0][0]]
		currentRewards.remove_at(0)
		return
	winners[user[2]] = [user[0], user[1], [currentRewards[0]]]
	winnerBoard[user[2]] = [user[1], currentRewards[0][0]]
	currentRewards.remove_at(0)


func addNewRewards(newReward):
	currentRewards.append(newReward)
