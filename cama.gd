extends Node3D

@onready var jugador = get_tree().get_first_node_in_group("jugador")

func _process(delta):
	if jugador == null:
		return
	var distancia = global_position.distance_to(jugador.global_position)
	if distancia < 2.5:
		jugador.puede_esconderse = true
		jugador.cama_posicion = global_position
	else:
		jugador.puede_esconderse = false
		jugador.escondido = false
		jugador.camara.position = jugador.posicion_normal
