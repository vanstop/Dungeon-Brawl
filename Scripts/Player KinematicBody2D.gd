extends KinematicBody2D

# Declare member variables here.
var tag = "Player"
var nickName = " "
var hp = 100
var points = 0
var playerSpeed = 100

#Constante que armazena o "caminho" do tiro
const Shoot = preload("res://Instantiables/Shoot KinematicBody2D.tscn")
#Constante que armazena o "caminho" da Font
const font = preload("res://Fonts/HUD_dynamicfont.tres")

#É usada para animar o player
var isMoving = false
#Direção para qual o player vai se mover, definida atraves do código do botão
var angleOfMotion = Vector2()

#Variáveis que passam a posição e o angulo do seu player para o celular dos outros
puppet var slave_angleOfMotion = null
puppet var slave_position = Vector2()

func init(nick, start_position, is_master):
	#Define que o nick deste player é igual ao nick digitado anteriormente pelo usuario
	nickName = nick
	#Define que a posição do player é a posição definida pela rede
	global_position = start_position
	#Se o este personagem for o master, o personagem que o jogador esta controlando, então ele vai exibir o Self Circle
	if is_master:
		$"Self Circle Sprite".visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#Chama a função animate, sem isso ela é criada mas não é usada
	_animate()
	
	#Se o jogador fizer 100 pontos ou mais
	if points >= 100:
		#Carrega a cena de venceu
		
		#warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scenes/Win Node2D.tscn")
	
	#Se a vida do player acabar
	if hp <= 0:
		#Mantem a vida em 0, assegurando que ela não assumira valores negativos
		hp = 0
		#Se o jogador estiver conectado, exceuta a função de morrer
		if NetworkSystem.isConnected:
			rpc("_Die")
		#Caso contrario, vai para a tela de derrota
		else:
			#warning-ignore:return_value_discarded
			get_tree().change_scene("res://Scenes/Lose Node2D.tscn")
	
# Igual ao _process mas serve para lidar com a fisica do jogo
func _physics_process(delta):
	#Se o player estiver conectado
	if NetworkSystem.isConnected:
		#Se o player for o personagem principal daquele celular
		if is_network_master():
			#Se o player possuir uma direção para ir ele se move
			_move(delta, angleOfMotion)
			#Passa a sua posição e sua rotação para os outros jogadores no mapa
			rset_unreliable('slave_position', position)
			rset('slave_angleOfMotion', angleOfMotion)
		else:
			#Caso este seja apenas uma instancia do player na tela de outras pessoas
			#Recebe a posição e rotação do player original
			position = slave_position
			_move(delta, slave_angleOfMotion)
	#Caso o player esteja offline, ele apenas move
	else:
		_move(delta, angleOfMotion)
		
func _move(delta, angle):
	if angle != null:
		#Diz que esta se movendo
		isMoving = true
		
		#Move o player na Direção desejada, com a velocidade por segundo desejada
		
		#warning-ignore:return_value_discarded
		move_and_collide(angle * playerSpeed * delta)
	else:
		#Diz que não esta se movendo
		isMoving = false

#Escreve o nome do player acima de sua cabeça
func _draw():
	draw_string(font, Vector2($"Player AnimatedSprite".position.x - 30, $"Player AnimatedSprite".position.y - 20), nickName, Color(1.0, 1.0, 1.0))

func _animate():
	#Executa a animação de acordo com o estado do player
	if isMoving:
		$"Player AnimatedSprite".play("Walk")
	else:
		$"Player AnimatedSprite".play("Idle")

sync func _Die():
	#Se quem morreu for a instancia principal deste celular
	if is_network_master():
		#Remove o peer
		get_tree().set_network_peer(null)
		#Diz que o player não esta mais conectado
		NetworkSystem.isConnected = false
		#Vai para a tela de perdeu
		
		#warning-ignore:return_value_discarded
		get_tree().change_scene('res://Scenes/Lose Node2D.tscn')
		
sync func _shoot():
	#Instancia um novo tiro e armazena-o na variavel shoot
	var shoot = Shoot.instance()
	#A posição inicial do tiro é a mesma do player
	shoot.global_position = position
	#A rotação do tiro é igual a da arma
	shoot.rotation = $"Player AnimatedSprite/Gun Sprite".angleToShoot
	#Adiciona o tiro na cena
	get_parent().add_child(shoot)
	#Toca o som de atirando
	$"Player AudioStreamPlayer2D"._play_ShootSound()
