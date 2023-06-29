extends Node

var password = "ThisIsTheTestPassword"

var loggedIn = false

func _ready():
	connect2DB()
	multiplayer.peer_disconnected.connect(self.peerDisconnected)

func connect2DB():
	var peer = ENetMultiplayerPeer.new()
	var secondMultiplayerApi = SceneMultiplayer.new()
	print_tree_pretty()
	get_tree().set_multiplayer(secondMultiplayerApi, "/root/Db") 
	peer.create_client('10.0.0.19', 1203)
	secondMultiplayerApi.multiplayer_peer = peer
	secondMultiplayerApi.set_root_path("/root/Db")


@rpc("any_peer","reliable")
func signin(Userpassword):
	if Userpassword == password:
		loggedIn = true
	rpc_id(1, "returnSignInRequest", loggedIn)

@rpc("any_peer", "reliable")
func returnSignInRequest(result):
	pass

func peerDisconnected(id:int):
	loggedIn = false

@rpc("reliable")
func addGiftCard(giftCard):
	if loggedIn == true:
		JackPot.addNewRewards(giftCard)


