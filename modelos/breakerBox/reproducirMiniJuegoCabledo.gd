# cableado.gd
extends Area3D

var player_inside = false
var minijuego_scene = preload("res://minijuego_cables.tscn")
var minijuego_instance = null

func _ready():
	if GameState.cables_reparados:
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	print("cableado listo, monitoring: ", monitoring)

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		player_inside = true
		body.cerca_de_cableado = true
		body.texto_interaccion.text = "C - Reparar cables"
		body.texto_interaccion.visible = true

func _on_body_exited(body):
	if body.is_in_group("jugador"):
		player_inside = false
		body.cerca_de_cableado = false
		body.texto_interaccion.visible = false

func _input(event):
	if player_inside and event is InputEventKey and event.keycode == KEY_C and event.pressed:
		abrir_minijuego()

func abrir_minijuego():
	if minijuego_instance != null:
		return
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.bloqueado = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	minijuego_instance = minijuego_scene.instantiate()
	get_tree().root.add_child(minijuego_instance)
	minijuego_instance.completado.connect(_on_puzzle_completado)
	minijuego_instance.cancelado.connect(_on_puzzle_cancelado)

func _on_puzzle_completado():
	cerrar_minijuego()
	GameState.marcar_cables()  # ← agrega esto
	MisionHUD.actualizar()


	# Activar enemigo
	var enemigo = get_tree().get_first_node_in_group("enemigo_cables")
	if enemigo:
		enemigo.activar()
	queue_free()

func _on_puzzle_cancelado():
	cerrar_minijuego()

func cerrar_minijuego():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		jugador.bloqueado = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if minijuego_instance:
		minijuego_instance.queue_free()
		minijuego_instance = null
