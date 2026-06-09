extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	pass

	if body.is_in_group("jugador"):
		
		body.puerta_cercana = get_parent()

func _on_body_exited(body):
	pass

	if body.is_in_group("jugador"):
		pass
		body.puerta_cercana = null
