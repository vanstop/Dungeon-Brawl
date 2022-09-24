extends Node2D

# Declare member variables here. Examples:
#Constantes que armazenam o "caminho" paras as cenas Player, Controles e Inimigos
const Player = preload("res://Instantiables/Player KinematicBody2D.tscn")
const Controles = preload("res://Instantiables/Controles CanvasLayer.tscn")
const EnemySpawner = preload("res://Instantiables/EnemySpawner Node2D.tscn")
const HUD = preload("res://Instantiables/HUD Node2D.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#Conecta funções do Sistema de rede do Godot a funções deste código
# warning-ignore:return_value_discarded
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
# warning-ignore:return_value_discarded
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	#Cria uma instancia, clone, do player e armazena-o
	var new_player = Player.instance()
	#Salva o nome do player como sendo seu ID unico usado para identificalo no jogo
	new_player.name = str(get_tree().get_network_unique_id())
	#Define o player como o Network Master da sua instancia de jogo, ou seja, no seu proprio celular o jogador passa a ter permições adicionais
	#Usamos o Network Master tambem para exibir o jogador com uma aparencia diferente no próprio celular a fim de se identificar
	new_player.set_network_master(get_tree().get_network_unique_id())
	#Adiciona este player a cena
	add_child(new_player)
	#Cria uma variavel chamada info e armazena as próprias informações
	var info = NetworkSystem.self_data
	#Inicializa o player, dando a ele uma pocição inicial e uma aparencia dependendo de quem controla o player
	new_player.init(info.name, info.position, true)
	
	#Adiciona uma instancia, clone, dos objetos para a cena
	
	var new_HUD = HUD.instance()
	#Adiciona a referencia de quem é o player para a HUD
	new_HUD.player = new_player
	#Adiciona a HUD para a cena
	add_child(new_HUD)
	
	var new_Controles = Controles.instance()
	#Adiciona a referencia de quem é o player para os botões touch
	new_Controles.get_child(0).player = new_player
	new_Controles.get_child(1).player = new_player
	new_Controles.get_child(1).gun = new_player.find_node("Gun Sprite", true, false)
	#Adiciona os controles para a cena
	add_child(new_Controles)
	
	#Se o jogador estiver offline, cria o gerador de inimigos
	if !NetworkSystem.isConnected:
		var new_EnemySpawner = EnemySpawner.instance()
		#Adiciona a referencia de quem é o player para o enemy spawner
		new_EnemySpawner.player = new_player
		#Adiciona o enemySpawner na cena
		add_child(new_EnemySpawner)
	
func _on_player_disconnected(id):
	#Quando um player for desconectado do servidor este player é removido da lista de players
	get_node(str(id)).queue_free()
# warning-ignore:return_value_discarded
	get_tree().change_scene('res://Scenes/Win Node2D.tscn')

func _on_server_disconnected():

	#Quando o servidor é desconectado todos os jogadores são mandados de volta ao menu
# warning-ignore:return_value_discarded
	get_tree().change_scene('res://Scenes/Win Node2D.tscn')
