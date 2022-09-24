extends Sprite

#Declare member variables here. Examples:

#Direção para qual a arma vai apontar, definida atraves do código do botão
var angleToShoot = 0

puppet var slave_angleToShoot = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if NetworkSystem.isConnected:
		if is_network_master():
			rset('slave_angleToShoot', angleToShoot)
		else:
			angleToShoot = slave_angleToShoot
	
	#Aplica a rotação do analogico na arma
	rotation = angleToShoot
	
	#Espelha a arma e o player de acordo com a sua direção da arma, evita que a arma fique de ponta cabeça e faz o player olhar na direção que esta mirando
	#Verifica se eu estou olhando para a direita
	if abs(rotation) <= 1.5:
		#A arma não fica fica espelhada
		flip_v = false;
		#O pai da arma ,Player AnimatedSprite, não fica espelhado
		get_parent().flip_h = false
	else:
		#A arma fica fica espelhada
		flip_v = true;
		#O pai da arma ,Player AnimatedSprite, fica espelhado
		get_parent().flip_h = true
