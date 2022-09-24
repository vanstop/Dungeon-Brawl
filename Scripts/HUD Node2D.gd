extends Node2D

# Declare member variables here. Examples:
#Armazena o "caminho" para o player para poder acessar suas variaveis
var player
#Armazena o "caminho" para font que nós criamos
const font = preload("res://Fonts/HUD_dynamicfont.tres")


func _process(_delta):
	#Função que atualiza a função _draw, sem ela a barra de vida aparece mas não desce quando perdemos vida
	update()

func _draw():
	#Desenha fundo da barra de vida na cor branca
	draw_rect(Rect2(Vector2(20,20), Vector2(200,20)),Color.white, true)
	#Desenha a barra de vida aqui usamos hp como um parametro para fazer com que a barra diminuia de acordo com a vida
	#Usamos Color(1 - player.hp/100, player.hp/100, 1) para que a cor da barra de vida mude de acordo com a quantidade, na duvida utilize apenas Color.green
	draw_rect(Rect2(Vector2(20,20), Vector2(player.hp * 2,20)),Color(1 - player.hp/100, player.hp/100, 0), true)
	#Desenha a pontuação na tela
	draw_string(font, Vector2(20, 60), "Pontos: " + str(player.points), Color(1.0, 1.0, 1.0))
