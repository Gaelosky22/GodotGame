# enemigo_cables.gd
extends Node3D

var posiciones = [
	Vector3(141.3076, 9.5, -44.728),
	Vector3(109.3855, 9.5, -47.7839),
	Vector3(111.4977, 9.5, -13.2112),
	Vector3(109.7287, 9.5, 3.940888),
	Vector3(83.2144, 9.5, -0.99497),
	Vector3(59.99074, 9.5, 3.672941),
	Vector3(17.02985, 9.5, 3.153524)
]

var activo = false
var visible_enemigo = false
var timer_aparicion: Timer
var timer_desaparicion: Timer
var primera_vez = true

@onready var animacion: AnimationPlayer = $AnimationPlayer

func _ready():
	visible = false
	timer_aparicion = Timer.new()
	timer_aparicion.one_shot = true
	timer_aparicion.timeout.connect(_aparecer)
	add_child(timer_aparicion)
	
	timer_desaparicion = Timer.new()
	timer_desaparicion.one_shot = true
	timer_desaparicion.timeout.connect(_desaparecer)
	add_child(timer_desaparicion)

func activar():
	activo = true
	primera_vez = true
	# Primera aparición siempre en posición 0, a los 2 segundos
	timer_aparicion.wait_time = 2.0
	timer_aparicion.start()

func _aparecer():
	if not activo:
		return
	
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		return
	await _parpadeo_pantalla()
	
	# Elegir posición más cercana al jugador
	if primera_vez:
		global_position = posiciones[0]
		primera_vez = false
	else:
		var pos_elegida = posiciones[1]
		var distancia_min = jugador.global_position.distance_to(posiciones[1])
		for i in range(2, posiciones.size()):
			var dist = jugador.global_position.distance_to(posiciones[i])
			if dist < distancia_min:
				distancia_min = dist
				pos_elegida = posiciones[i]
		global_position = pos_elegida
	
	# Mirar al jugador
	look_at(jugador.global_position, Vector3.UP)
	
	visible = true
	visible_enemigo = true
	
	var anims = ["thc4_arma|st_idle_battle", "thc4_arma|st_idle_howl", "thc4_arma|st_idle"]
	animacion.play(anims[randi_range(0, anims.size() - 1)])
	
	timer_desaparicion.wait_time = 1.2
	timer_desaparicion.start()
	
	set_process(true)

func _parpadeo_pantalla():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		return
	
	var capa = CanvasLayer.new()
	capa.layer = 50
	jugador.add_child(capa)
	
	var rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(rect)
	
	# Parpadeo 1
	var tween = jugador.create_tween()
	tween.tween_property(rect, "color", Color(0, 0, 0, 1), 0.1)
	tween.tween_property(rect, "color", Color(0, 0, 0, 0), 0.1)
	# Parpadeo 2
	tween.tween_property(rect, "color", Color(0, 0, 0, 1), 0.1)
	tween.tween_property(rect, "color", Color(0, 0, 0, 0), 0.1)
	await tween.finished
	capa.queue_free()

func _process(_delta):
	if not visible_enemigo:
		return
	# Seguir mirando al jugador siempre
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		look_at(jugador.global_position, Vector3.UP)
		rotate_y(deg_to_rad(180))

func _desaparecer():
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		return
	
	# Revisar si el jugador sobrevivió
	var quieto = _jugador_quieto(jugador)
	var linterna_apagada = not jugador.linterna_encendida
	
	if quieto and linterna_apagada:
		# Sobrevivió — desaparecer y programar siguiente aparición
		visible = false
		visible_enemigo = false
		set_process(false)
		var espera = randf_range(5.0, 10.0)
		timer_aparicion.wait_time = espera
		timer_aparicion.start()
	else:
		# Matar al jugador
		visible = false
		visible_enemigo = false
		set_process(false)
		jugador.recibir_golpe()
		jugador.recibir_golpe()
		jugador.recibir_golpe()

func _jugador_quieto(jugador) -> bool:
	# Revisar velocidad horizontal del jugador
	var vel = jugador.velocity
	vel.y = 0
	return vel.length() < 0.1
