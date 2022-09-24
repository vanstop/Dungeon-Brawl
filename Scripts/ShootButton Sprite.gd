extends Sprite

# Declare member variables here. Examples:
var player
var gun

#Raio do sprite maior do botão, o chamado conteiner
const bigRadius = 100
#Raio do sprite menor do botão, o botão em si
const smallRadius = 50

#Posição que o MoveButton Inicia
var initialPos = Vector2.ZERO
#Armazena qual dedo esta controlando este botão
var touchIndex = -1
#Armazena se o botão esta em uso ou não
var activated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	initialPos = global_position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#A visibilidade do filho da arma, Range Sprite, depende deste botão estar em, uso ou não.
	gun.get_child(0).visible = activated
	
	# Se o botão não esta em uso, ele fica transparente
	if activated:
		modulate.a8 = 200
	else:
		modulate.a8 = 100
	
func _input(event):
	#Verifica se o evento é do tipo touchscreen
	if event is InputEventScreenTouch:
		#Verifica se o dedo esta na tela
		if event.is_pressed():
			#Se tocou do lado direito da tela e o botão ainda não estava em uso
			if event.position.x > get_viewport().size.x/2 and !activated:
				#Define que agora o botão esta em uso
				activated = true
				#Salvar qual dedo esta comandando o botão
				touchIndex = event.index
				#Move o Analogico para a posição do toque
				global_position = event.position
				
		#Caso o dedo não esteja na tela
		#Verifica se o dedo que saiu da tela era o dedo que comandava a este botão
		elif touchIndex == event.index:
			#Define que agora o botão não esta mais em uso
			activated = false
			#Salvar que nenhum dedo comanda mais este botão
			touchIndex = -1
			#Move o Analogico para a posição do inicial
			global_position = initialPos
			$"Button Sprite".position = Vector2.ZERO
			
			#Quando o botão for solto se o player estiver conectado
			if NetworkSystem.isConnected:
				#Se o player for o Network Master
				if player.is_network_master():
					#Envia o comando para que todas as suas instancias atirem
					player.rpc('_shoot')
			#Caso contrario
			else:
				#O player atira normalmente
				player._shoot()
			
	#Verifica se o evento é do tipo ScreenDrag e se o dedo que esta sendo arrastado é o que esta comandando este botão
	if event is InputEventScreenDrag and event.index == touchIndex:
		#Cria uma variavel para armazenar a distancia entre o dedo e o container do analogico
		var dist = global_position.distance_to(event.position)
		#Cria uma variavel para a armazenar a direção que o botão vai se mover
		var vect = (event.position - global_position).normalized()
		#Diz para a arma apontar na "mesma" direção que o dedo
		gun.angleToShoot = event.position.angle_to_point(global_position)
		
		#Verifica se o botão ja chegou na borda do container
		if dist + smallRadius > bigRadius:
			#Limita a movimentação do botão
			dist = bigRadius - smallRadius
			
		#Move o botão para a posição nescessaria
		$"Button Sprite".position = vect * dist
