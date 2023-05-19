extends Node



func _ready():
	connect2DB()

func connect2DB():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client('127.0.0.1', 1203)
	multiplayer.multiplayer_peer = peer
	
