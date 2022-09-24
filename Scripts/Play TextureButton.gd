extends TextureButton

#Quando este botão for pressionado
func _pressed():
	#Muda para a cena Jogo
	
	#warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Game Node2D.tscn")
