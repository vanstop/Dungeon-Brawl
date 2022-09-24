extends Control

# Declare member variables here. Examples:
var _player_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	#Escreve o endereço de ip do jogador na tela
	$"My IP Label".text = "Meu IP: " + str(IP.get_local_addresses()[0])

func _on_Host_TextureButton_pressed():
	#Se o jogador tentar criar um server sem definir o seu nome, o nome se torna o IP
	if _player_name == "":
		_player_name = "Host: " + str(IP.get_local_addresses()[0])
	#Cria um servidor
	NetworkSystem.create_server(_player_name)
	#Carrega a cena de jogo multiplayer
	
	#warning-ignore:return_value_discarded
	get_tree().change_scene('res://Scenes/Multiplayer Game Node2D.tscn')


func _on_Client_TextureButton_pressed():
	#Se o jogador tentar se conectar a um server sem definir o seu nome, o nome se torna o IP
	if _player_name == "":
		_player_name = "Client: " + str(IP.get_local_addresses()[0])
	#Se conecta ao servidor
	NetworkSystem.connect_to_server(_player_name)
	#Carrega a cena de jogo multiplayer
	
	#warning-ignore:return_value_discarded
	get_tree().change_scene('res://Scenes/Multiplayer Game Node2D.tscn')


func _on_Back_TextureButton_pressed():
	#Se apertar o botão voltar o jogador volta ao menu
# warning-ignore:return_value_discarded
	get_tree().change_scene('res://Scenes/Menu Node2D.tscn')


func _on_Nickname_LineEdit_text_changed(new_text):
	#Armazena este texto na variável _player_name
	_player_name = new_text


func _on_Server_IP_LineEdit_text_changed(new_text):
	#Quando o jogador digitar um ip, este ip sera salvo como ip padrão, e assim usado na hora de se conectar ao servidor
	NetworkSystem.DEFAULT_IP = new_text
