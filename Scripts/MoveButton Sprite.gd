extends Sprite

# Declare member variables here. Examples:
var player

const bigRadius = 100
const smallRadius = 50

#Posição que o MoveButton Inicial
var initialPos = Vector2.ZERO
#Armazena qual dedo esta controlando este botão
var touchIndex = -1
var activated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	initialPos = global_position
	player.angleOfMotion = null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
			#Se tocou do lado esquerdo da tela e o botão ainda não estava em uso
			if event.position.x < get_viewport().size.x/2 and !activated:
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
			#Avisa o player que ele não deve mais se mover
			player.angleOfMotion = null
			
	#Verifica se o evento é do tipo ScreenDrag e se o dedo que esta sendo arrastado é o que esta comandando este botão
	if event is InputEventScreenDrag and event.index == touchIndex:
		#Cria uma variavel para armazenar a distancia entre o dedo e o container do analogico
		var dist = global_position.distance_to(event.position)
		#Cria uma variavel para a armazenar a direção que o botão vai se mover
		var vect = (event.position - global_position).normalized()
		#Diz para o player se mover na "mesma" direção que o dedo
		player.angleOfMotion = vect
		
		#Verifica se o botão ja chegou na borda do container
		if dist + smallRadius > bigRadius:
			#Limita a movimentação do botão
			dist = bigRadius - smallRadius
			
		#Move o botão para a posição nescessaria
		$"Button Sprite".position = vect * dist
