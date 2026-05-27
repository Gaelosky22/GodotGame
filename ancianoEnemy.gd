extends CharacterBody3D

@export var velocidad_caminar: float = 3.3
@export var rango_vision: float = 18.0
@export var angulo_vision: float = 120.0
@export var rango_ataque: float = 1.5
@export var zona_min: Vector2 = Vector2(-5, -5)
@export var zona_max: Vector2 = Vector2(5, 5)

var gravedad: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var delay_ataque: float = 1.8
@export var tiempo_detencion_ataque: float = 0.7

var puede_atacar = true
var atacando = false
var jugador: Node3D = null
var velocidad_actual: float = 3.0
var destino: Vector3 = Vector3.ZERO
var tiempo_espera: float = 0.0
var tiempo_intentando_llegar = 0.0
var tiempo_maximo_destino = 3.0
var ultima_posicion = Vector3.ZERO
@onready var audio_detectar = get_node_or_null("detectarJugador")
@onready var audio_ambiente = get_node_or_null("../musicaFondo")

enum Estado { RONDANDO, ESPERANDO, PERSIGUIENDO }
var estado: Estado = Estado.ESPERANDO
@onready var anim = $Ch30_nonPBR/AnimationPlayer

func _ready():
	ultima_posicion = global_position
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() > 0:
		jugador = jugadores[0]

	velocidad_actual = velocidad_caminar

	if audio_ambiente:
		audio_ambiente.play()
	else:
		print("ADVERTENCIA: no se encontró musicaFondo")

	if not audio_detectar:
		print("ADVERTENCIA: no se encontró detectarJugador")

	_nuevo_destino_aleatorio()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravedad * delta
	else:
		velocity.y = 0.0

	_actualizar_estado()

	match estado:
		Estado.RONDANDO:
			_rondar(delta)
		Estado.ESPERANDO:
			_esperar(delta)
		Estado.PERSIGUIENDO:
			_perseguir()

	move_and_slide()

func _jugador_esta_escondido() -> bool:
	if jugador == null:
		return false

	if "escondido" in jugador:
		return jugador.escondido == true

	if jugador.get("escondido") == true:
		return true

	if jugador.get("oculto") == true:
		return true

	return false

func _actualizar_estado():
	if jugador == null:
		return

	if _jugador_esta_escondido():
		if estado == Estado.PERSIGUIENDO:
			_entrar_rondando()
		return

	var ve = _puede_ver_jugador()

	if ve and estado != Estado.PERSIGUIENDO:
		_entrar_persecucion()
	elif not ve and estado == Estado.PERSIGUIENDO:
		_entrar_rondando()

func _puede_ver_jugador() -> bool:
	if jugador == null:
		return false

	if _jugador_esta_escondido():
		return false

	var distancia = global_position.distance_to(jugador.global_position)
	if distancia > rango_vision:
		return false

	var dir_jugador = jugador.global_position - global_position
	dir_jugador.y = 0

	if dir_jugador.length() <= 0.1:
		return false

	dir_jugador = dir_jugador.normalized()

	var dir_frente = -global_transform.basis.z
	dir_frente.y = 0

	if dir_frente.length() <= 0.1:
		return false

	dir_frente = dir_frente.normalized()

	var angulo = rad_to_deg(dir_frente.angle_to(dir_jugador))
	if angulo > angulo_vision / 2.0:
		return false

	var espacio = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP,
		jugador.global_position + Vector3.UP
	)

	query.exclude = [self, jugador]

	var resultado = espacio.intersect_ray(query)

	if resultado:
		return false

	return true

func _entrar_persecucion():
	estado = Estado.PERSIGUIENDO
	velocidad_actual = velocidad_caminar * 1.5
	print("PERSIGUIENDO")

	if audio_ambiente and audio_ambiente.playing:
		audio_ambiente.stop()

	if audio_detectar and not audio_detectar.playing:
		audio_detectar.play()

func _entrar_rondando():
	estado = Estado.RONDANDO
	velocidad_actual = velocidad_caminar
	print("RONDANDO")

	velocity.x = 0.0
	velocity.z = 0.0

	if audio_detectar and audio_detectar.playing:
		audio_detectar.stop()

	if audio_ambiente and not audio_ambiente.playing:
		audio_ambiente.play()

	_nuevo_destino_aleatorio()

func _rondar(delta):
	var distancia = Vector2(
		global_position.x - destino.x,
		global_position.z - destino.z
	).length()

	if distancia < 0.5:
		estado = Estado.ESPERANDO
		tiempo_espera = randf_range(1.5, 3.5)
		tiempo_intentando_llegar = 0.0
		velocity.x = 0.0
		velocity.z = 0.0
		return

	tiempo_intentando_llegar += delta

	var se_movio = global_position.distance_to(ultima_posicion) > 0.05

	if se_movio:
		tiempo_intentando_llegar = 0.0
		ultima_posicion = global_position

	if tiempo_intentando_llegar >= tiempo_maximo_destino:
		print("ATASCADO, GIRANDO 120 GRADOS")

		var direccion_actual = -global_transform.basis.z
		direccion_actual.y = 0.0

		if direccion_actual.length() <= 0.1:
			direccion_actual = Vector3.FORWARD

		direccion_actual = direccion_actual.normalized()

		var lado = 1
		if randi() % 2 == 0:
			lado = -1

		var direccion_nueva = direccion_actual.rotated(
			Vector3.UP,
			deg_to_rad(120 * lado)
		).normalized()

		destino = global_position + direccion_nueva * 5.0

		destino.x = clamp(destino.x, zona_min.x, zona_max.x)
		destino.z = clamp(destino.z, zona_min.y, zona_max.y)

		tiempo_intentando_llegar = 0.0
		ultima_posicion = global_position

		_mover_hacia(destino, velocidad_actual)
		return

	_mover_hacia(destino, velocidad_actual)

func _atacar_jugador():
	if jugador == null:
		return

	if _jugador_esta_escondido():
		return

	if not is_inside_tree():
		return

	puede_atacar = false
	atacando = true
	estado = Estado.PERSIGUIENDO

	print("ATACANDO")

	if jugador.has_method("recibir_golpe"):
		jugador.recibir_golpe()

	var tree2 = get_tree()
	if tree2 == null:
		return

	await tree2.create_timer(tiempo_detencion_ataque).timeout

	if not is_inside_tree():
		return

	if jugador != null and not _jugador_esta_escondido():
		var direccion = jugador.global_position - global_position
		direccion.y = 0

		if direccion.length() > 0.1:
			direccion = direccion.normalized()
			look_at(global_position + direccion, Vector3.UP)

	atacando = false
	estado = Estado.PERSIGUIENDO

	var tree = get_tree()
	if tree == null:
		return

	await tree.create_timer(tiempo_detencion_ataque).timeout

	if not is_inside_tree():
		return

	puede_atacar = true
	estado = Estado.PERSIGUIENDO

func _esperar(delta):
	velocity.x = 0.0
	velocity.z = 0.0

	tiempo_espera -= delta

	if tiempo_espera <= 0:
		_nuevo_destino_aleatorio()
		estado = Estado.RONDANDO

func _perseguir():
	if jugador == null:
		return

	if _jugador_esta_escondido():
		_entrar_rondando()
		return

	if atacando:
		velocity.x = 0.0
		velocity.z = 0.0

		if jugador != null and not _jugador_esta_escondido():
			var direccion = jugador.global_position - global_position
			direccion.y = 0

			if direccion.length() > 0.1:
				direccion = direccion.normalized()
				look_at(global_position + direccion, Vector3.UP)

		return

	var distancia = global_position.distance_to(jugador.global_position)

	if distancia <= rango_ataque:
		velocity.x = 0.0
		velocity.z = 0.0

		if puede_atacar:
			_atacar_jugador()

		return

	_mover_hacia(jugador.global_position, velocidad_actual)

func _mover_hacia(objetivo: Vector3, vel: float):
	var direccion = objetivo - global_position
	direccion.y = 0.0

	if direccion.length() > 0.1:
		direccion = direccion.normalized()
		velocity.x = direccion.x * vel
		velocity.z = direccion.z * vel
		look_at(global_position + direccion, Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

func _nuevo_destino_aleatorio():
	destino = Vector3(
		randf_range(zona_min.x, zona_max.x),
		global_position.y,
		randf_range(zona_min.y, zona_max.y)
	)

	print("Nuevo destino:", destino)
