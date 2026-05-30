extends Node3D

var abierta = false

func _ready():
	add_to_group("puertas_generador")

func interactuar():
	if abierta: return

	var gm = get_tree().get_root().find_child("GameManager", true, false)
	if gm and gm.generadores_encendidos >= 2:
		_abrir()
	else:
		# Mostrar cuántos faltan
		var faltan = 2 - gm.generadores_encendidos
		var jugadores = get_tree().get_nodes_in_group("jugador")
		if not jugadores.is_empty():
			jugadores[0].mostrar_mensaje_temporal("Necesitas encender " + str(faltan) + " generador(es) más")

func abrir_automatico():
	# Llamado por GameManager cuando los 2 generadores están encendidos
	_abrir()

func _abrir():
	abierta = true
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", rotation.y + deg_to_rad(90), 1.0)
	print("¡Mega puerta abierta!")
