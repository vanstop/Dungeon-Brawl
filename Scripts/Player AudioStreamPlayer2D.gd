extends AudioStreamPlayer2D

# Declare member variables here. Examples:
var shootSound = preload("res://Sounds/SFX/146730__leszek-szary__shoot.wav")
var hurtSound = preload("res://Sounds/SFX/428631__satchdev__warning-sound.wav")

func _play_ShootSound():
	#Seleciona o som de tiro como som atual e depois toca-o
	stream = shootSound
	play()

func _start_HurtSound():
	#Caso o som ainda não esteja tocando, sem este if o som de aviso iria começar varias vezes seguidas e assim não ouviriamos nada.
	if !playing:
		#Define o som atual para o som de aviso de dano e toca-o
		stream = hurtSound
		play()
