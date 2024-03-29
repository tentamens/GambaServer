extends Node

const DEFAULTPORT: int = 8080

@export var numberRushOutcomeOdds = 0.5



func _ready():
	
	
	
	multiplayer.peer_connected.connect(self._peer_connected)
	multiplayer.peer_disconnected.connect(self.peerDisconnected)
	start_server()

func start_server():
	var port: int = DEFAULTPORT
	var peer = ENetMultiplayerPeer.new()
	var server_tls_options = TLSOptions.server(load("res://Data/game-server.key"), load("res://Data/game-server.crt"))
	peer.create_server(port, 2000)
	peer.host.dtls_server_setup(server_tls_options)
	multiplayer.multiplayer_peer = peer
	print("server Starting")
	


func _peer_connected(id:int):
	pass


func peerDisconnected(id:int):
	Data.playerStateSubtract(id)


@rpc("any_peer")
func serverConnectPlayer(clientID: int, playerName) -> void:
	
	clientID = multiplayer.get_remote_sender_id()
	var UID
	if playerName == null:
		UID = str(str(clientID) + str(Time.get_ticks_msec()) + "a")
	
	var content = 200
	
#	if LBS.sortedArray.find(playerName) != -1:
#		var lbs = LBS.sortedArray
#		lbs[lbs.bsearch(playerName)] = [lbs[0],lbs[1], UID]
	
	Data.playerStateAdd(clientID, content)
	rpc_id(clientID, "returnUID", UID)



@rpc("reliable")
func returnUID(UID):
	pass


@rpc("any_peer", "reliable")
func calculatePegValue(zone, clientID, num):
	
	var betValue = BallState.loadBallScore(num)
	
	var Score = Data.loadPlayerScore(clientID)
	
	
	var multiple = getMultiple(zone)
	
	Score += betValue * multiple
	
	Score = round(Score)
	
	Data.playerStateAdd(clientID, Score)
	
	rpc_id(clientID, "updateScore", Score)
	


@rpc("reliable")
func updateScore(score):
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
	
	# all the buttons
	var nums = [1,2,4,5,6,7,8,9,10,11,12,13,14,15]
	
	# players mini game data
	var numbers = [[],[],[],[],[]]
	
	numbers[3] = currentBet
	
	numbers[4] = 1.0
	
	var i = 0
	while i < 5:
		
		if i < 2:
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
		
	
	score = round(score)
	Mines.addMineScore(clientID,numbers)
	


@rpc("any_peer", "reliable")
func clickMineProcessSend(num: int):
	
	var clientID = multiplayer.get_remote_sender_id()
	
	if Mines.checkIfCurrentlyActive(clientID) == false:
		return
	
	
	var numbers = Mines.loadMineScore(clientID)
	
	
	var result = calcMineResult(numbers, num)
	
	
	# no gain or loss was clicked
	if result == 4:
		numbers[4] += 0.5
		Mines.addMineScore(clientID,numbers)
		rpc_id(clientID, "clickMineProcessSendReturn", null, null, null, numbers[4], null)
		return
	
	# lose all
	if result == 2:
		var score = Data.loadPlayerScore(clientID)
		
		
		score -= numbers[3]
		
		score = round(score)
		Data.playerStateAdd(clientID, score)
		Mines.mineStateSubtract(clientID)
		
		score = Data.loadPlayerScore(clientID)
		
		rpc_id(clientID, "clickMineProcessSendReturn", score, num, result, 0, numbers)
		return
	
	
	var scoreMultiplyer = Mines.mineWinningRates[result]
	var score = Data.loadPlayerScore(clientID)
	
	numbers[result].erase(num)
	Mines.addMineScore(clientID,numbers)
	
	
	
	var earnings = (numbers[3] * scoreMultiplyer) * numbers[4]
	
	
	
	score -= numbers[3]
	
	score += (numbers[3] * scoreMultiplyer) * numbers[4]
	
	numbers[4] += 0.25
	
	numbers[3] = earnings
	score = round(score)
	Data.playerStateAdd(clientID, score)
	
	
	#number[4] = multiplyer
	rpc_id(clientID, "clickMineProcessSendReturn", score, num, result, numbers[4], null)
	




@rpc("reliable")
func clickMineProcessSendReturn(score, num, result, multiplyer, fullBoard):
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
	



#@rpc("unreliable")
#func pillarBetRequestReturn(outcome):
#	pass


@rpc("any_peer", "reliable")
func numberRushBetRequestRecieve(currentBet):
	
	var clientID = multiplayer.get_remote_sender_id()
	var random = RandomNumberGenerator.new()
	
	var rand = snappedf(random.randf_range(0.1, 1), 0.1)
	
	var multi = (1 / (1 + pow(2.7182, (2*(rand * -2.5) + 4)) )) * 3
	
	
	
	if multi < 1:
		multi = 0.5
	
	randomize()
	var number = random.randf_range(0.1, (3 * multi))
	
	
	var score = Data.loadPlayerScore(clientID)
	
	if score < currentBet or currentBet == 0:
		return
	
	
	var numberRushOutcome = numberRushOutcomeOdds * (pow(number,2))
	
	
	numberRushOutcome += 1
	
	numberRushOutcome = snapped(numberRushOutcome, 0.05)
	
	NumberRush.addNumberScore(clientID, [numberRushOutcome, currentBet])
	
	rpc_id(clientID, "numberRushBetRequestReturn")
	


@rpc("reliable")
func numberRushBetRequestReturn():
	pass


@rpc("any_peer", "reliable")
func numberRushUpdateProccessReceive(currentMultiple):
	var clientID = multiplayer.get_remote_sender_id()
	var state = NumberRush.loadNumberScore(clientID)
	
	if NumberRush.checkIfCurrentlyActive(clientID):
		return
	
	
	if currentMultiple < state[0]:
		return
	
	var score = Data.loadPlayerScore(clientID)
	
	score -= state[1]
	score = round(score)
	Data.loadPlayerScoreSubtractBet(clientID, state[1])
	NumberRush.numberStateSubtract(clientID)
	
	rpc_id(clientID, "numberRushCrash", score)
	


@rpc("reliable")
func numberRushCrash(score):
	pass


@rpc("any_peer", "reliable")
func NumberRushCashOutRecieve(currentMultiple):
	var clientID = multiplayer.get_remote_sender_id()
	
	if NumberRush.checkIfCurrentlyActive(clientID):
		return
	
	var state = NumberRush.loadNumberScore(clientID)
	var score = Data.loadPlayerScore(clientID)
	
	NumberRush.numberStateSubtract(clientID)
	
	if currentMultiple > state[0]:
		score -= state[1]
		Data.loadPlayerScoreSubtractBet(clientID, state[1])
		rpc_id(clientID, "numberRushCrash", score)
		NumberRush.numberStateSubtract(clientID)
		return
	
	score -= state[1]
	score += state[1] * currentMultiple
	score = round(score)
	
	Data.playerStateAdd(clientID, score)
	
	NumberRush.numberStateSubtract(clientID)
	
	rpc_id(clientID, "numberRushWin", score, state[0])
	


@rpc("reliable")
func numberRushWin(score, outcome):
	pass


@rpc("any_peer", "reliable")
func getLeaderBoardSend(Score):
	var clientId = multiplayer.get_remote_sender_id()
	rpc_id(clientId, "getLeaderBoardReturn", LBS.publicLB)


@rpc("reliable")
func getLeaderBoardReturn(leaderBoard):
	pass


@rpc("any_peer","reliable")
func cashOutRequestRecieve(UID, username):
	var clientId = multiplayer.get_remote_sender_id()
	var score = Data.loadPlayerScore(clientId)
	LBS.addNewMember(username, score, UID)


func scoreChange(change, username):
	rpc("addScoreChangeUpdate", change, username)


@rpc("reliable")
func addScoreChangeUpdate(change,username):
	pass


@rpc("reliable","any_peer")
func loadRewardPageReceive(UID):
	var winnings = JackPot.checkUIDforWinner(UID)
	rpc_id(multiplayer.get_remote_sender_id(), "loadRewardPageReturn", winnings, JackPot.winnerBoard)


@rpc("reliable")
func loadRewardPageReturn(WinningsInfo, winners):
	pass


var loggedIn = false
var loggedInId
var password = "ThisIsTheTempPassword"
var id = "{79a73c27-d8a6-11ed-ac67-806e6f6e6963}"



@rpc("reliable", "any_peer")
func signIn(Userpassword, ident):
	if Userpassword == password and id == str(ident):
		loggedInId = multiplayer.get_remote_sender_id()
		loggedIn = true
		print("logged in")


@rpc("reliable", "any_peer")
func addGiftCard(giftcard, passwords, ids):
	print("hello")
	if loggedIn == false:
		return
	print(checkCrediention(ids, passwords))
	if checkCrediention(ids, passwords) == false:
		return
	
	JackPot.addNewRewards(giftcard)


@rpc("reliable","any_peer")
func logout():
	loggedIn == false


func checkCrediention(ident, Userpassword):
	if id != str(ident):
		return false
	
	if Userpassword == password:
		
		return true
	
	return false

