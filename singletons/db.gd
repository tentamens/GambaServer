extends Node



func _ready():
	connect2DB()

func connect2DB():
	var peer = ENetMultiplayerPeer.new()
	var secondMultiplayerApi = SceneMultiplayer.new()
	get_tree().set_multiplayer(secondMultiplayerApi, "/root/db")  
	peer.create_client('127.0.0.1', 1203)
	secondMultiplayerApi.multiplayer_peer = peer
	
