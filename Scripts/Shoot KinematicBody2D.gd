extends KinematicBody2D

# Declare member variables here. Examples:
var moveSpeed = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	#Quando o tiro for instanciado, ele se move extremamente rapido, teleporta 70 pixels, assim o tiro parece sair da arma e não de dentro do player
	position.x += cos(rotation) * 70
	position.y += sin(rotation) * 70

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#Cria uma variavel que armazena a direção para onde o tiro vai se mover, separade em X e Y
	var direction = Vector2(cos(rotation), sin(rotation))
	#Cria uma variavel, move o tiro e se ele colidir com algo salva essa informação
	var collision_info = move_and_collide(direction * moveSpeed * delta)
	
	#Se o tiro colidiu com algo
	if collision_info:
		#Se o nome do node com que eu colidi contem TileMap
		if "TileMap" in collision_info.collider.name:
			#Se auto destroi
			if NetworkSystem.isConnected:
				rpc("_DestroySelf")
			else:
				_DestroySelf()
		elif collision_info.collider.tag == "Player" and collision_info.collider.is_network_master():
			if NetworkSystem.isConnected:
				rpc("_DestroySelf")
			else:
				_DestroySelf()
			collision_info.collider.hp -= 20
				
sync func _DestroySelf():
	get_parent().remove_child(self)
	
