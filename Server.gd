extends Node

const DEFAULTPORT: int = 4242

@onready var numberRushOutcomeOdds = 1


func _ready():
	
	
	multiplayer.peer_connected.connect(self._peer_connected)
	multiplayer.peer_disconnected.connect(self.peerDisconnected)
	start_server()




func start_server():
	var port: int = DEFAULTPORT
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer



func _peer_connected(id:int):
	var content = 200
	
	Data.playerStateAdd(id, content)
	rpc_id(id, "createPlayerNode")

func peerDisconnected(id:int):
	Data.playerStateSubtract(id)


@rpc("any_peer")
func serverConnectPlayer(clientID: int, playerName: String) -> void:
	var content = 200

	Data.playerStateAdd(clientID, content)
	rpc_id(clientID, "createPlayerNode")



@rpc("any_peer", "reliable")
func calculatePegValue(zone, clientID, num):
	
	var betValue = BallState.loadBallScore(num)
	
	var Score = Data.loadPlayerScore(clientID)
	
	
	var multiple = getMultiple(zone)
	
	Score += betValue * multiple
	
	
	Data.playerStateAdd(clientID, Score)
	
	rpc_id(clientID, "updateScore", Score)
	


@rpc("reliable")
func updateScore(score):
	pass


@rpc
func createPlayerNode():
	pass



func getMultiple(zone):
	if zone == "far":
		return 10
	if zone == "RL":
		return 0.5
	if zone == "mid":
		return 3
	if zone == "middle":
		return 0.2

@rpc("any_peer", "reliable")
func genData(clientID):
	rpc_id(clientID, "retreiveGenData", Data.loadData("res://Data/GeneralData.json"))


@rpc("reliable")
func retreiveGenData(data):
	pass


@rpc("any_peer", "reliable")
func requestBallSpawnSend(currentBet):
	
	var clientID = multiplayer.get_remote_sender_id()
	var score = Data.loadPlayerScore(clientID)
	
	print(currentBet)
	
	if score < currentBet or currentBet == 0:
		
		return
	
	
	Data.loadPlayerScoreSubtractBet(clientID, currentBet)
	
	
	var spawnPos = randf_range(569, 609)
	
	score = Data.loadPlayerScore(clientID)
	
	var BallID = Time.get_unix_time_from_system() + randf_range(1, 1000000)
	
	BallState.addBallScore(BallID, currentBet)
	
	
	rpc_id(clientID, "requestBallSpawnReturn",[score,Vector2(spawnPos, 90),BallID])



@rpc("reliable")
func requestBallSpawnReturn(Info):
	pass

@rpc("any_peer","reliable")
func betMinesRequestSend(currentBet):
	
	
	var clientID = multiplayer.get_remote_sender_id()
	
	
	var score = Data.loadPlayerScore(clientID)
	
	
	if score <= currentBet or currentBet == 0:
		return
	
	
	var nums = [1,2,4,5,6,7,8,9,10,11,12,13,14,15]
	
	var numbers = [[],[],[], []]
	
	numbers[3] = currentBet
	
	var i = 0
	while i < 5:
		
		if i < 3:
			var numberAdded = nums.pick_random()
			numbers[0].append(numberAdded)
			nums.erase(numberAdded)
		
		if i < 4:
			var numberAdded = nums.pick_random()
			numbers[1].append(numberAdded)
			nums.erase(numberAdded)
		
		
		var numberAdded = nums.pick_random()
		numbers[2].append(numberAdded)
		nums.erase(numberAdded)
		
		
		
		i += 1
		
	
	
	Mines.addMineScore(clientID,numbers)
	




@rpc("any_peer", "reliable")
func clickMineProcessSend(num: int):
	
	print("proccess")
	
	var clientID = multiplayer.get_remote_sender_id()
	
	if Mines.checkIfCurrentlyActive(clientID) == false:
		return
	
	
	var numbers = Mines.loadMineScore(clientID)
	
	
	var result = calcMineResult(numbers, num)
	
	
	# no gain or loss was clicked
	if result == 4:
		return
	
	
	# lose all
	if result == 2:
		var score = Data.loadPlayerScore(clientID)
		
		score -= numbers[3]
		
		
		Data.playerStateAdd(clientID, score)
		Mines.mineStateSubtract(clientID)
		
		score = Data.loadPlayerScore(clientID)
		
		rpc_id(clientID, "clickMineProcessSendReturn", score, num, result)
		return
	
	
	var scoreMultiplyer = Mines.mineWinningRates[result]
	var score = Data.loadPlayerScore(clientID)
	
	numbers[result].erase(num)
	Mines.addMineScore(clientID,numbers)
	
	
	var earnings = numbers[3] * scoreMultiplyer
	
	score -= numbers[3]
	
	score += (numbers[3] * scoreMultiplyer)
	
	numbers[3] = earnings
	Data.playerStateAdd(clientID, score)
	
	rpc_id(clientID, "clickMineProcessSendReturn", score, num, result)
	


@rpc("reliable")
func clickMineProcessSendReturn(score, num, result):
	pass

func calcMineResult(numbers, num):
	if numbers[0].has(num):
		return 0
	if numbers[1].has(num):
		return 1
	if numbers[2].has(num):
		return 2
	return 4

@rpc("any_peer", "reliable")
func cashOutMinesRecieve():
	var clientID = multiplayer.get_remote_sender_id()
	
	Mines.mineStateSubtract(clientID)
	
	

@rpc("any_peer", "reliable")
func pillarBetRequestRecieve(currentBet):
	var clientID = multiplayer.get_remote_sender_id()
	
	var score = Data.loadPlayerScore(clientID)
	
	if score <= currentBet or currentBet == 0:
		return
	
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	var outcome = random.randf_range(1, 100)
	
	rpc_id(clientID, "pillarBetRequestReturn", outcome)
	



@rpc("unreliable")
func pillarBetRequestReturn(outcome):
	pass

@rpc("any_peer", "reliable")
func numberRushBetRequestRecieve(currentBet):
	var clientID = multiplayer.get_remote_sender_id()
	var random = RandomNumberGenerator.new()
	var number = random.randf_range(0.1, 2)
	
	var score = Data.loadPlayerScore(clientID)
	
	var numberRushOutcome = numberRushOutcomeOdds * (pow(number,2))
	
	
	numberRushOutcome *= 1.5
	
	numberRushOutcome = snapped(numberRushOutcome, 0.01)
	
	NumberRush.addNumberScore(clientID, [numberRushOutcome, currentBet])
	
	rpc_id(1, "numberRushBetRequestReturn")
	

@rpc("reliable")
func numberRushBetRequestReturn():
	pass


@rpc("any_peer", "reliable")
func numberRushUpdateProccessReceive(currentMultiple):
	var clientID = multiplayer.get_remote_sender_id()
	var state = NumberRush.loadNumberScore(clientID)
	NumberRush.numberStateSubtract(clientID)
	
	if currentMultiple < state[0]:
		return
	
	var score = Data.loadPlayerScore(clientID)
	
	score -= state[1]
	Data.loadPlayerScoreSubtractBet(clientID, state[1])
	
	rpc_id(clientID, "numberRushCrash", score)
	



@rpc("reliable")
func numberRushCrash(score):
	pass

@rpc("any_peer", "reliable")
func NumberRushCashOutRecieve(currentMultiple):
	var clientID = multiplayer.get_remote_sender_id()
	var state = NumberRush.loadNumberScore(clientID)
	var score = Data.loadPlayerScore(clientID)
	
	NumberRush.numberStateSubtract(clientID)
	
	if currentMultiple < state[0]:
		score -= state[1]
		Data.loadPlayerScoreSubtractBet(clientID, state[1])
		rpc_id(clientID, "numberRushCrash", score)
		return
	
	score -= state[1]
	score += score * currentMultiple
	
	Data.playerStateAdd(clientID, score)
	
	rpc_id(clientID, "numberRushWin", score)
	

@rpc("reliable")
func numberRushWin(score):
	pass


