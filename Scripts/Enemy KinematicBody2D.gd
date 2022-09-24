extends KinematicBody2D

# Declare member variables here. Examples:
var player

#Variaveis que definem a vida, a velocidade e o tamanho do inimigo
var hp = 100
var moveSpeed = 50
	
func _process(delta):
	update()
	#Se a distancia entre o inimigo e o player for menos que 10 pixels e o inimigo estiver vivo
	if global_position.distance_to(player.global_position) < 20 and hp > 0:
		#O player perde 10 de vida por segundo
		player.hp -= 10 * delta
		#Toca o som de aviso de quando o player esta recebendo dano
		player.get_child(2)._start_HurtSound()
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	#Perseguir o player
	if hp > 0:
		#Armazena o angulo até o player
		var alvo = get_angle_to(player.global_position)
		#Cria uma variavel que armazena a direção para onde o inimigo vai se mover, separade em X e Y
		var direction = Vector2(cos(alvo), sin(alvo))
		#Cria uma variavel, move o inimigo e se ele colidir com algo salva essa informação
		var collision_info = move_and_collide(direction * moveSpeed * delta)
		
		#Se o inimigo colidiu com algo
		if collision_info:
			#Se o nome do node com que eu colidi contem Shoot KenmaticBody2D
			if "Shoot KinematicBody2D" in collision_info.collider.name:
				#Leva 50 de dano
				hp -= 50
				#Toca o som de levando dano
				$"AudioStreamPlayer2D".play()
				#Destroi o tiro
				get_parent().remove_child(collision_info.collider)
				
	else:
		#Toca a animação de morrer
		$AnimatedSprite.play("Die")
		#Se a animação ja acabou
		if($AnimatedSprite.frame == 6):
			#Adiciona 10 pontos para o player
			player.points += 10
			#Destroi a si mesmo
			get_parent().remove_child(self)

func _draw():
	#Desenha fundo da barra de vida, são passados valores locais na posição, assim começamos a desenha a barra de (-10, -10) até (20, 5)
	draw_rect(Rect2(Vector2.ONE * -10, Vector2(20,5)),Color.white, true)
	#Desenha a barra de vida aqui usamos hp como um parametro para fazer com que a barra diminuia de acordo com a vida
	draw_rect(Rect2(Vector2.ONE * -10, Vector2(hp/5,5)),Color.red, true)
