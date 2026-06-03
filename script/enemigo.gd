extends CharacterBody3D

@export var zona_min: Vector2 = Vector2(-16.0, -41.0)
@export var zona_max: Vector2 = Vector2(18.0, 37.0)

var gravedad = ProjectSettings.get_setting("physics/3d/default_gravity")
var jugador: Node3D = null
var puede_atacar = true
var destino: Vector3 = Vector3.ZERO
var tiempo_espera: float = 0.0
var posicion_sonido: Vector3 = Vector3.ZERO
var escucho_sonido: bool = false
var tiempo_mismo_lugar: float = 0.0
var ultima_pos_check: Vector3 = Vector3.ZERO
var generadores_investigados: Array = []

var velocidad_base: float = 3.3
var velocidad_actual: float = 3.3
var timer_cambio_velocidad: float = 0.0

var tiempo_juego: float = 0.0
var fase: int = 0
var golpes_dados: int = 0
var timer_sin_ver_jugador: float = 0.0

@onready var audio_detectar = get_node_or_null("detectarJugador")
@onready var audio_monstruo = get_node_or_null("AudioMonstruo")
@onready var anim: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer

enum Estado { PATRULLANDO, ESPERANDO, INVESTIGANDO, ACECHANDO, PERSIGUIENDO, ASUSTANDO, DESAPARECIENDO }
var estado: Estado = Estado.PATRULLANDO

func _ready():
	add_to_group("enemigo")
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() > 0:
		jugador = jugadores[0]
	ultima_pos_check = global_position
	velocidad_actual = randf_range(2.5, 3.8)
	_reproducir("Model|Idle")
	await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
	_nuevo_destino()

func _physics_process(delta):
	tiempo_juego += delta

	if tiempo_juego < 10.0:
		fase = 0
	elif tiempo_juego < 20.0:
		fase = 1
	else:
		fase = 2

	if not is_on_floor():
		velocity.y -= gravedad * delta
	else:
		velocity.y = 0.0

	# Velocidad variable
	timer_cambio_velocidad -= delta
	if timer_cambio_velocidad <= 0.0:
		timer_cambio_velocidad = randf_range(4.0, 12.0)
		if estado == Estado.PATRULLANDO:
			velocidad_actual = randf_range(velocidad_base * 0.6, velocidad_base * 1.3)

	# Anti-atasco
	if global_position.distance_to(ultima_pos_check) < 0.2:
		tiempo_mismo_lugar += delta
		if tiempo_mismo_lugar > 3.0:
			_nuevo_destino()
			tiempo_mismo_lugar = 0.0
	else:
		tiempo_mismo_lugar = 0.0
	ultima_pos_check = global_position

	_detectar_sonidos()
	_actualizar_estado(delta)

	match estado:
		Estado.PATRULLANDO: _patrullar()
		Estado.ESPERANDO: _esperar(delta)
		Estado.INVESTIGANDO: _investigar()
		Estado.ACECHANDO: _acechar()
		Estado.PERSIGUIENDO: _perseguir()
		Estado.ASUSTANDO, Estado.DESAPARECIENDO:
			velocity.x = 0.0
			velocity.z = 0.0

	_actualizar_audio_monstruo()
	move_and_slide()

# ─── DETECCIÓN ─────────────────────────────────────────────────────────────

func _puede_ver_jugador() -> bool:
	if jugador == null or _jugador_escondido(): return false
	var dist = global_position.distance_to(jugador.global_position)
	if dist > 15.0: return false
	var dir = (jugador.global_position - global_position)
	dir.y = 0
	if dir.length() < 0.1: return false
	var frente = -global_transform.basis.z
	frente.y = 0
	if frente.length() < 0.1: return false
	if rad_to_deg(frente.normalized().angle_to(dir.normalized())) > 50.0: return false
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
	return jugador != null and jugador.get("escondido") == true

func _detectar_sonidos():
	if jugador == null or _jugador_escondido(): return
	var dist = global_position.distance_to(jugador.global_position)
	if Input.is_key_pressed(KEY_SHIFT) and dist < 10.0:
		posicion_sonido = jugador.global_position
		escucho_sonido = true
	# Generadores — solo investiga una vez cada uno
	for gen in get_tree().get_nodes_in_group("generadores"):
		if gen.get("encendido") == true and not generadores_investigados.has(gen):
			var d = global_position.distance_to(gen.global_position)
			if d < 25.0 and estado != Estado.PERSIGUIENDO:
				posicion_sonido = gen.global_position
				escucho_sonido = true
				generadores_investigados.append(gen)

func escuchar_puerta(pos: Vector3):
	if estado == Estado.PERSIGUIENDO: return
	posicion_sonido = pos
	escucho_sonido = true

# ─── ESTADOS ───────────────────────────────────────────────────────────────

func _actualizar_estado(delta):
	if estado == Estado.ASUSTANDO or estado == Estado.DESAPARECIENDO: return

	var ve = _puede_ver_jugador()

	if ve:
		timer_sin_ver_jugador = 0.0
		match fase:
			0:
				# Solo reacciona si el jugador LO mira — se detecta si el jugador lo tiene enfrente
				if _jugador_mira_al_enemigo():
					if estado != Estado.ASUSTANDO:
						_asustar_y_huir()
			1:
				if estado != Estado.ACECHANDO and estado != Estado.ASUSTANDO:
					if randf() < 0.4:
						_asustar_y_huir()
					else:
						estado = Estado.ACECHANDO
			2:
				if estado != Estado.PERSIGUIENDO:
					_entrar_persecucion()
		return

	# Perdió de vista
	if estado == Estado.PERSIGUIENDO:
		if _jugador_escondido():
			_entrar_patrulla()
		else:
			if escucho_sonido:
				estado = Estado.INVESTIGANDO
			else:
				_entrar_patrulla()
		return

	if estado == Estado.ACECHANDO:
		timer_sin_ver_jugador += delta
		if timer_sin_ver_jugador > 8.0:
			_entrar_patrulla()
		return

	if escucho_sonido and estado == Estado.PATRULLANDO:
		estado = Estado.INVESTIGANDO
		escucho_sonido = false
		return

	# Contador 45s solo en fase 1 y 2
	if fase >= 1 and (estado == Estado.PATRULLANDO or estado == Estado.ESPERANDO):
		timer_sin_ver_jugador += delta
		if timer_sin_ver_jugador > 22.0:
			timer_sin_ver_jugador = 0.0
			_teletransportar_detras_jugador()

func _jugador_mira_al_enemigo() -> bool:
	if jugador == null: return false
	var dir_jugador_frente = -jugador.global_transform.basis.z
	dir_jugador_frente.y = 0
	var dir_a_enemigo = (global_position - jugador.global_position)
	dir_a_enemigo.y = 0
	if dir_a_enemigo.length() < 0.1: return false
	var angulo = rad_to_deg(dir_jugador_frente.normalized().angle_to(dir_a_enemigo.normalized()))
	return angulo < 40.0

func _entrar_persecucion():
	estado = Estado.PERSIGUIENDO
	velocidad_actual = randf_range(5.0, 6.5)
	if audio_detectar and not audio_detectar.playing:
		audio_detectar.play()

func _entrar_patrulla():
	estado = Estado.PATRULLANDO
	velocidad_actual = randf_range(velocidad_base * 0.6, velocidad_base * 1.2)
	if audio_detectar and audio_detectar.playing:
		audio_detectar.stop()
	escucho_sonido = false
	_nuevo_destino()

# ─── COMPORTAMIENTOS ───────────────────────────────────────────────────────

func _patrullar():
	var dist_xz = Vector2(global_position.x - destino.x, global_position.z - destino.z).length()
	if dist_xz < 1.0:
		estado = Estado.ESPERANDO
		tiempo_espera = randf_range(0.8, 4.0)
		velocity.x = 0.0
		velocity.z = 0.0
		_reproducir("Model|Idle")
		return
	_mover_hacia(destino, velocidad_actual)
	_reproducir("Model|Walk")

func _esperar(delta):
	velocity.x = 0.0
	velocity.z = 0.0
	tiempo_espera -= delta
	if tiempo_espera <= 0:
		if randf() < 0.15:
			_teletransportar_aleatorio()
		else:
			_nuevo_destino()
			estado = Estado.PATRULLANDO

func _investigar():
	var dist_xz = Vector2(global_position.x - posicion_sonido.x, global_position.z - posicion_sonido.z).length()
	if dist_xz < 1.5:
		escucho_sonido = false
		_entrar_patrulla()
		return
	_mover_hacia(posicion_sonido, velocidad_base * 1.2)
	_reproducir("Model|Walk")

func _acechar():
	if jugador == null or _jugador_escondido():
		_entrar_patrulla()
		return
	var dist = global_position.distance_to(jugador.global_position)
	if dist < 2.5:
		_asustar_y_huir()
		return
	_mover_hacia(jugador.global_position, velocidad_base * 0.7)
	_reproducir("Model|Walk")

func _perseguir():
	if jugador == null or _jugador_escondido():
		_entrar_patrulla()
		return
	var dist = global_position.distance_to(jugador.global_position)
	if dist <= 2.5:
		velocity.x = 0.0
		velocity.z = 0.0
		_mirar_a(jugador.global_position)
		if puede_atacar:
			_atacar_y_huir()
		return
	_mover_hacia(jugador.global_position, velocidad_actual)
	_reproducir("Model|Run")

# ─── ATAQUE ────────────────────────────────────────────────────────────────

func _atacar_y_huir():
	puede_atacar = false
	_reproducir("Model|Attack")
	if jugador and jugador.has_method("recibir_golpe"):
		jugador.recibir_golpe()
	golpes_dados += 1
	await get_tree().create_timer(0.6).timeout
	if not is_inside_tree(): return

	# Tercer golpe — jumpscare
	if golpes_dados >= 3:
		if jugador and jugador.has_method("morir"):
			jugador.morir()
		return

	# Huir rápido
	estado = Estado.DESAPARECIENDO
	if audio_detectar and audio_detectar.playing:
		audio_detectar.stop()
	var dir_escape = (global_position - jugador.global_position)
	dir_escape.y = 0
	if dir_escape.length() > 0.1:
		dir_escape = dir_escape.normalized()
	destino = global_position + dir_escape * randf_range(10.0, 18.0)
	destino.x = clamp(destino.x, zona_min.x, zona_max.x)
	destino.z = clamp(destino.z, zona_min.y, zona_max.y)
	velocidad_actual = randf_range(6.0, 9.0)
	global_position = _posicion_aleatoria_lejos(15.0)
	estado = Estado.PATRULLANDO
	_nuevo_destino()

	await get_tree().create_timer(4.0).timeout
	if not is_inside_tree(): return
	puede_atacar = true
	velocidad_actual = randf_range(velocidad_base * 0.6, velocidad_base * 1.2)

# ─── ASUSTAR Y HUIR ────────────────────────────────────────────────────────

func _asustar_y_huir():
	estado = Estado.ASUSTANDO
	velocity.x = 0.0
	velocity.z = 0.0
	_mirar_a(jugador.global_position)
	_reproducir("Model|Idle")

	if randf() < 0.25 and audio_monstruo:
		audio_monstruo.play()

	await get_tree().create_timer(randf_range(0.5, 1.2)).timeout
	if not is_inside_tree(): return

	var dir_escape = (global_position - jugador.global_position)
	dir_escape.y = 0
	if dir_escape.length() > 0.1:
		dir_escape = dir_escape.normalized()
	destino = global_position + dir_escape * randf_range(8.0, 20.0)
	destino.x = clamp(destino.x, zona_min.x, zona_max.x)
	destino.z = clamp(destino.z, zona_min.y, zona_max.y)
	velocidad_actual = randf_range(5.0, 8.0)
	estado = Estado.PATRULLANDO
	_reproducir("Model|Run")

	await get_tree().create_timer(3.0).timeout
	if not is_inside_tree(): return
	if estado == Estado.PATRULLANDO:
		velocidad_actual = randf_range(velocidad_base * 0.6, velocidad_base * 1.2)

# ─── TELETRANSPORTE ────────────────────────────────────────────────────────

func _teletransportar_aleatorio():
	estado = Estado.DESAPARECIENDO
	visible = false
	await get_tree().create_timer(randf_range(2.0, 5.0)).timeout
	if not is_inside_tree(): return
	global_position = _posicion_aleatoria_lejos(12.0)
	visible = true
	estado = Estado.PATRULLANDO
	_nuevo_destino()

func _teletransportar_detras_jugador():
	if jugador == null: return
	estado = Estado.DESAPARECIENDO
	visible = false
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree(): return
	var dir_detras = jugador.global_transform.basis.z.normalized()
	var nueva_pos = jugador.global_position + dir_detras * randf_range(2.0, 3.5)
	nueva_pos.y = global_position.y
	nueva_pos.x = clamp(nueva_pos.x, zona_min.x, zona_max.x)
	nueva_pos.z = clamp(nueva_pos.z, zona_min.y, zona_max.y)
	global_position = nueva_pos
	visible = true
	if audio_monstruo:
		audio_monstruo.play()
	if fase >= 2:
		_entrar_persecucion()
	else:
		_asustar_y_huir()

func _posicion_aleatoria_lejos(dist_min: float) -> Vector3:
	for i in range(15):
		var pos = Vector3(
			randf_range(zona_min.x, zona_max.x),
			global_position.y,
			randf_range(zona_min.y, zona_max.y)
		)
		if jugador == null or pos.distance_to(jugador.global_position) > dist_min:
			return pos
	return global_position

# ─── AUDIO ─────────────────────────────────────────────────────────────────

func _actualizar_audio_monstruo():
	if jugador == null or audio_monstruo == null: return
	if estado == Estado.PERSIGUIENDO:
		var dist = global_position.distance_to(jugador.global_position)
		if dist < 8.0 and not audio_monstruo.playing:
			audio_monstruo.play()
	elif audio_monstruo.playing and estado != Estado.ASUSTANDO:
		audio_monstruo.stop()

# ─── UTILIDADES ────────────────────────────────────────────────────────────

func _nuevo_destino():
	destino = Vector3(
		randf_range(zona_min.x, zona_max.x),
		global_position.y,
		randf_range(zona_min.y, zona_max.y)
	)

func _mover_hacia(objetivo: Vector3, vel: float):
	var dir = objetivo - global_position
	dir.y = 0.0
	if dir.length() > 0.3:
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
	if anim == null: return
	if anim.current_animation == nombre: return
	if anim.has_animation(nombre):
		anim.play(nombre)
