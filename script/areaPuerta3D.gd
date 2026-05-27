extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print("Entró algo al área:", body.name)

	if body.is_in_group("jugador"):
		print("Jugador detectado")
		body.puerta_cercana = get_parent()

func _on_body_exited(body):
	print("Salió algo del área:", body.name)

	if body.is_in_group("jugador"):
		print("Jugador salió")
		body.puerta_cercana = null
