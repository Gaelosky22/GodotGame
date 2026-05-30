extends CharacterBody3D

@export var velocidad_caminar: float = 3.0
@export var velocidad_correr: float = 5.5
@export var rango_vision: float = 15.0
@export var angulo_vision: float = 90.0
@export var rango_ataque: float = 1.5
@export var rango_escuchar_generador: float = 20.0
@export var rango_alerta_monstruo: float = 8.0  # distancia para sonar audio monstruo

var gravedad = ProjectSettings.get_setting("physics/3d/default_gravity")
var jugador: Node3D = null
var puede_atacar = true
var atacando = false

# Puntos de patrulla
var puntos: Array[Node3D] = []
var indice_punto: int = 0

# Última posición de sonido escuchado
var posicion_sonido: Vector3 = Vector3.ZERO
var escucho_sonido: bool = false

var tiempo_espera: float = 0.0
var velocidad_actual: float = 0.0

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var audio_detectar = get_node_or_null("detectarJugador")
@onready var audio_monstruo = get_node_or_null("AudioMonstruo")
@onready var modelo_anim: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer
var anim_actual: String = ""

enum Estado { PATRULLANDO, ESPERANDO, INVESTIGANDO, PERSIGUIENDO }
var estado: Estado = Estado.PATRULLANDO

func _ready():
	add_to_group("enemigo")
	velocidad_actual = velocidad_caminar

	# Buscar jugador
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() > 0:
		jugador = jugadores[0]

	# Buscar puntos de patrulla
	for nombre in ["punto1", "punto2", "punto3", "punto4"]:
		var n = get_tree().get_root().find_child(nombre, true, false)
		if n:
			puntos.append(n)

	_reproducir("Model|Idle")
	await get_tree().create_timer(0.5).timeout
	_ir_siguiente_punto()

func _physics_process(delta):
	# Gravedad
	if not is_on_floor():
		velocity.y -= gravedad * delta
	else:
		velocity.y = 0.0

	_detectar_sonidos()
	_actualizar_estado()

	match estado:
		Estado.PATRULLANDO: _patrullar()
		Estado.ESPERANDO: _esperar(delta)
		Estado.INVESTIGANDO: _investigar()
		Estado.PERSIGUIENDO: _perseguir()

	# Audio monstruo cuando se acerca al jugador
	_actualizar_audio_monstruo()

	move_and_slide()

# ─── DETECCIÓN ─────────────────────────────────────────────────────────────

func _puede_ver_jugador() -> bool:
	if jugador == null or _jugador_escondido(): return false
	var dist = global_position.distance_to(jugador.global_position)
	if dist > rango_vision: return false

	var dir_jugador = (jugador.global_position - global_position)
	dir_jugador.y = 0
	if dir_jugador.length() < 0.1: return false
	dir_jugador = dir_jugador.normalized()

	var frente = -global_transform.basis.z
	frente.y = 0
	if frente.length() < 0.1: return false

	var angulo = rad_to_deg(frente.normalized().angle_to(dir_jugador))
	if angulo > angulo_vision / 2.0: return false

	# Raycast
	var espacio = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP,
		jugador.global_position + Vector3.UP
	)
	query.exclude = [self]
	var res = espacio.intersect_ray(query)
	if res and res.collider != jugador: return false
	return true

func _jugador_escondido() -> bool:
	if jugador == null: return false
	return jugador.get("escondido") == true

func _detectar_sonidos():
	# Escuchar pasos del jugador corriendo
	if jugador != null and not _jugador_escondido():
		var dist = global_position.distance_to(jugador.global_position)
		var corriendo = Input.is_key_pressed(KEY_SHIFT)
		if corriendo and dist < 10.0:
			_registrar_sonido(jugador.global_position)

	# Escuchar generadores encendidos
	for gen in get_tree().get_nodes_in_group("generadores"):
		if gen.get("encendido") == true:
			var dist = global_position.distance_to(gen.global_position)
			if dist < rango_escuchar_generador and estado != Estado.PERSIGUIENDO:
				_registrar_sonido(gen.global_position)

func _registrar_sonido(pos: Vector3):
	posicion_sonido = pos
	escucho_sonido = true

# ─── ESTADOS ───────────────────────────────────────────────────────────────

func _actualizar_estado():
	var ve_jugador = _puede_ver_jugador()

	if ve_jugador and estado != Estado.PERSIGUIENDO:
		_entrar_persecucion()
		return

	if not ve_jugador and estado == Estado.PERSIGUIENDO:
		if _jugador_escondido():
			_entrar_patrulla()
			return
		# Sigue yendo a la última posición conocida
		if escucho_sonido:
			estado = Estado.INVESTIGANDO

	if escucho_sonido and estado == Estado.PATRULLANDO:
		estado = Estado.INVESTIGANDO
		escucho_sonido = false

func _entrar_persecucion():
	estado = Estado.PERSIGUIENDO
	velocidad_actual = velocidad_correr
	if audio_detectar and not audio_detectar.playing:
		audio_detectar.play()

func _entrar_patrulla():
	estado = Estado.PATRULLANDO
	velocidad_actual = velocidad_caminar
	if audio_detectar and audio_detectar.playing:
		audio_detectar.stop()
	escucho_sonido = false
	_ir_siguiente_punto()

# ─── COMPORTAMIENTOS ───────────────────────────────────────────────────────

func _patrullar():
	if puntos.is_empty(): return
	if nav.is_navigation_finished():
		estado = Estado.ESPERANDO
		tiempo_espera = randf_range(1.5, 3.5)
		velocity.x = 0.0
		velocity.z = 0.0
		_reproducir("Model|Idle")
		return
	var siguiente = nav.get_next_path_position()
	_mover_hacia(siguiente, velocidad_actual)
	_reproducir("Model|Walk")

func _esperar(delta):
	velocity.x = 0.0
	velocity.z = 0.0
	tiempo_espera -= delta
	if tiempo_espera <= 0:
		_ir_siguiente_punto()
		estado = Estado.PATRULLANDO

func _investigar():
	nav.target_position = posicion_sonido
	if nav.is_navigation_finished():
		# Llegó al lugar del sonido, no encontró nada — patrulla
		escucho_sonido = false
		_entrar_patrulla()
		return
	var siguiente = nav.get_next_path_position()
	_mover_hacia(siguiente, velocidad_caminar * 1.3)
	_reproducir("Model|Walk")

func _perseguir():
	if jugador == null: return
	if _jugador_escondido():
		_entrar_patrulla()
		return

	var dist = global_position.distance_to(jugador.global_position)

	if dist <= rango_ataque:
		velocity.x = 0.0
		velocity.z = 0.0
		_mirar_a(jugador.global_position)
		if puede_atacar:
			_atacar()
		return

	nav.target_position = jugador.global_position
	var siguiente = nav.get_next_path_position()
	_mover_hacia(siguiente, velocidad_actual)
	_reproducir("Model|Run")

# ─── ATAQUE ────────────────────────────────────────────────────────────────

func _atacar():
	puede_atacar = false
	atacando = true
	_reproducir("Model|Attack")
	if jugador.has_method("recibir_golpe"):
		jugador.recibir_golpe()
	await get_tree().create_timer(0.8).timeout
	if not is_inside_tree(): return
	atacando = false
	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree(): return
	puede_atacar = true

# ─── AUDIO MONSTRUO ────────────────────────────────────────────────────────

func _actualizar_audio_monstruo():
	if jugador == null or audio_monstruo == null: return
	var dist = global_position.distance_to(jugador.global_position)
	if dist < rango_alerta_monstruo and estado == Estado.PERSIGUIENDO:
		if not audio_monstruo.playing:
			audio_monstruo.play()
	else:
		if audio_monstruo.playing:
			audio_monstruo.stop()

# ─── UTILIDADES ────────────────────────────────────────────────────────────

func _ir_siguiente_punto():
	if puntos.is_empty(): return
	indice_punto = (indice_punto + 1) % puntos.size()
	nav.target_position = puntos[indice_punto].global_position

func _mover_hacia(objetivo: Vector3, vel: float):
	var dir = objetivo - global_position
	dir.y = 0.0
	if dir.length() > 0.1:
		dir = dir.normalized()
		velocity.x = dir.x * vel
		velocity.z = dir.z * vel
		look_at(global_position + dir, Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

func _mirar_a(pos: Vector3):
	var dir = pos - global_position
	dir.y = 0
	if dir.length() > 0.1:
		look_at(global_position + dir.normalized(), Vector3.UP)

func _reproducir(nombre: String):
	if modelo_anim == null: return
	if anim_actual == nombre: return
	if modelo_anim.has_animation(nombre):
		anim_actual = nombre
		modelo_anim.play(nombre)
