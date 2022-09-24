extends TextureButton

#Quando este botão for pressionado
func _pressed():
	#Muda para a cena Multiplayer Lobby
	
	#warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Lobby Multiplayer Node2D.tscn")
