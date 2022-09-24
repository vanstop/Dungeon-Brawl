extends Node

#Iremos utilizar o sistema de conexão Peer-2-Peer onde os jogadores se conectam diretamente entre si, sem um servidor
#Apesar disso, um dos jogadores sera o host, que é o proprio server do jogo e é nomeado assim no código, e os outros jogadores serão os clients
#Podemos dizer que cada peer, representa um novo usuario na rede, seja ele host ou client

#IP no qual o server vai ser criado ou acessado
var DEFAULT_IP = '127.0.0.1'
#Porta lógica a ser utilizada pelos jogadores
const DEFAULT_PORT = 31415
#Numero máximo de jogadores
const MAX_PLAYERS = 2

var isConnected = false

#Lista que armazenará o players que estão conectados ao server
var players = { }
#Objeto que armazena, o nome e a posição de um jogador
var self_data = { name = '', position = Vector2(1240/2, 600/2) }

#Signals são como broadcasts que você cria.
#Você conecta os comunicadores aos receptores e depois envia/recebe o sinal para que algo seja executado

func _ready():
	#Conecta sinais emitidos pelo Godot sobre a conexão, a funções existentes neste código
	#Quando for detectado que o jogo foi desconectado rodamos a função _on_player_disconnect
	
	#warning-ignore:return_value_discarded
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	
	#Quando for detectado que o jogo foi conectado rodamos a função _on_player_connected
	
	#warning-ignore:return_value_discarded
	get_tree().connect('network_peer_connected', self, '_on_player_connected')

func create_server(player_nickname):
	#Armazena o nick digitado pelo jogador
	self_data.name = player_nickname
	#Define que o Host, o jogador que executou esta função, é o primeiro da lista de players.
	players[1] = self_data
	#Cria a variável peer. Basicamente, na rede somos todos representados por peers
	var peer = NetworkedMultiplayerENet.new()
	#Aqui criamos o server, na porta decidida previamente, e com um máximo de jogadores definidos.
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	#Diz que o peer que vai nos representar é esse que acabamos de criar
	get_tree().set_network_peer(peer)
	isConnected = true


func connect_to_server(player_nickname):
	#Armazena o nick digitado pelo jogador
	self_data.name = player_nickname
	#Quando for detectado que o jogador foi conectado ao host rodamos a função _connected_to_server
	
	#warning-ignore:return_value_discarded
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	#Cria a variavel peer. Basicamente, na rede somos todos representados por peers
	var peer = NetworkedMultiplayerENet.new()
	#Aqui criamos o client, que vai se conectar ao host que esta no ip descrito, e atraves da porta descrita
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	#Diz que o peer que vai nos representar é esse que acabamos de criar
	get_tree().set_network_peer(peer)
	isConnected = true

func _connected_to_server():
	#Armazena o ID do player que é usado pela rede
	var local_player_id = get_tree().get_network_unique_id()
	#Salva as informações desse jogador na lista players, usando como índice o deu ID
	players[local_player_id] = self_data
	#Um RPC Executa funções de forma remota em todos os scripts que a possuirem, inclusive os da rede
	#Faz com que todos os outros jogadores armazenem as informações deste jogador
	rpc('_send_player_info', local_player_id, self_data)
	isConnected = true

func _on_player_disconnected(id):
	#Caso um player se desconecte, as informações dele são apagadas
	players.erase(id)
	#warning-ignore:return_value_discarded
	get_tree().change_scene('res://Scenes/Win Node2D.tscn')
	
	
func _on_player_connected(connected_player_id):
	#No momento em que o player se conecta, 
	#Armazena o ID do player que é usado pela rede
	var local_player_id = get_tree().get_network_unique_id()
	#Se o jogador não for o host
	if not(get_tree().is_network_server()):
		#Este jogador pede as informações dos jogadores ja conectados para o host, e as armazena
		rpc_id(1, '_request_player_info', local_player_id, connected_player_id)
	isConnected = true

#Remote serve para avisar a Godot que essão função pode ser chamada por RPCs
remote func _request_player_info(request_from_id, player_id):
	#Se for o server
	if get_tree().is_network_server():
		#Envia ao jogador recem conectado as informações dos outros players
		rpc_id(request_from_id, '_send_player_info', player_id, players[player_id])

#Função usada caso o server precise solicitar as informações de todos os players novamente
remote func _request_players(request_from_id):
	if get_tree().is_network_server():
		for peer_id in players:
			if( peer_id != request_from_id):
				rpc_id(request_from_id, '_send_player_info', peer_id, players[peer_id])

remote func _send_player_info(id, info):
	#Armazena as informações do jogador desejado na lista players
	players[id] = info
	#Cria um variavel para armazenar uma instancia do player
	var new_player = load('res://Instantiables/Player KinematicBody2D.tscn').instance()
	#Armazena o nome deste player como sendo o ID dele
	new_player.name = str(id)
	#Define que este player tem o poder de controlar a conexão
	new_player.set_network_master(id)
	#Instancia este player na cena Game, assim os códigos deste player começam a rodar
	$'/root/Game Node2D/'.add_child(new_player)
	#Inicializa o player, passando para ele o nick a ser exibido, a posição inicial dele e se ele é ou não o player principal, para que possamos diferenciar nosso player dos outros
	new_player.init(info.name, info.position, true)

func update_position(id, position):
	#Atualiza a posição de jogador desejado
	players[id].position = position
