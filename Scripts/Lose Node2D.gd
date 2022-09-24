extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	#Remove o peer
	get_tree().set_network_peer(null)
	#Diz que o player não esta mais conectado
	NetworkSystem.isConnected = false
