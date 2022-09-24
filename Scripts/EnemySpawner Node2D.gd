extends Node2D

# Declare member variables here. Examples:
#Armazena o "caminho" do inimigo
const Enemy = preload("res://Instantiables/Enemy KinematicBody2D.tscn")

var player

#Gera um inimigo novo e reinicia o timer
func _spawn():
	#Gera um novo inimigo e armazena-o na variavel enemy
	var enemy = Enemy.instance()
	#Avisa para os inimigos quem é o player
	enemy.player = player
	#Adiciona o inimigo para a cena Jogo
	get_parent().add_child(enemy)
	#Diz que a posição do inimigo é aleatoria mas dentro da tela
	enemy.global_position = Vector2(rand_range(0, get_viewport().size.x), rand_range(0, get_viewport().size.y))
	#Reinicia o timer
	$"Timer".start()



func _on_Timer_timeout():
	_spawn()
