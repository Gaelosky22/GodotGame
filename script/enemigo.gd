extends CharacterBody3D

@export var velocidad_caminar: float = 3.3
@export var velocidad_correr: float = 6.5
@export var rango_vision: float = 14.0
@export var angulo_vision: float = 85.0
@export var rango_ataque: float = 2.2
@onready var area_ataque = get_node_or_null("AreaAtaque")

var pos_generador1: Vector3 = Vector3(15.22, 1.02, -22.11)
var pos_generador2: Vector3 = Vector3(16.47, 1.02, -30.48)
var pos_llave: Vector3 = Vector3(-1.34, 1.02, 31.93)
var pos_galon: Vector3 = Vector3(6.24, 1.02, -8.14)

var ruta_a: Array[Vector3] = [
	Vector3(-0.39, 1.02, -0.00), Vector3(0.06, 1.02, -2.80),
	Vector3(0.28, 1.02, -5.46), Vector3(0.57, 1.02, -9.55),
	Vector3(1.28, 1.02, -12.31), Vector3(4.34, 1.02, -13.30),
	Vector3(6.27, 1.02, -15.42), Vector3(6.66, 1.02, -16.96),
	Vector3(6.31, 1.02, -18.77), Vector3(5.60, 1.02, -20.20),
	Vector3(4.57, 1.02, -21.42), Vector3(3.69, 1.02, -22.76),
	Vector3(2.96, 1.02, -24.18), Vector3(2.50, 1.02, -25.71),
	Vector3(2.51, 1.02, -27.17), Vector3(2.93, 1.02, -28.71),
	Vector3(4.32, 1.02, -31.26), Vector3(5.85, 1.02, -32.04),
	Vector3(7.67, 1.02, -32.08), Vector3(8.68, 1.02, -31.69),
	Vector3(10.79, 1.02, -30.69), Vector3(11.74, 1.02, -29.32),
	Vector3(11.84, 1.02, -28.16), Vector3(12.15, 1.02, -26.44),
	Vector3(13.04, 1.02, -23.76), Vector3(13.46, 1.02, -21.72),
	Vector3(13.54, 1.02, -19.72), Vector3(13.32, 1.02, -17.99),
	Vector3(13.01, 1.02, -16.95), Vector3(13.50, 1.02, -15.12),
	Vector3(14.34, 1.02, -13.98), Vector3(14.69, 1.02, -12.96),
	Vector3(15.10, 1.02, -10.08), Vector3(15.01, 1.02, -9.08),
	Vector3(14.41, 1.02, -6.25), Vector3(13.86, 1.02, -5.32),
	Vector3(12.43, 1.02, -3.06), Vector3(11.34, 1.02, -1.29),
	Vector3(10.32, 1.02, 0.62), Vector3(10.15, 1.02, 2.68),
	Vector3(10.75, 1.02, 4.74), Vector3(11.95, 1.02, 6.33),
	Vector3(13.23, 1.02, 7.87), Vector3(13.82, 1.02, 8.68),
	Vector3(14.37, 1.02, 10.67), Vector3(14.25, 1.02, 12.49),
	Vector3(13.60, 1.02, 14.64), Vector3(12.69, 1.02, 16.41),
	Vector3(11.75, 1.02, 17.99), Vector3(10.00, 1.02, 20.43),
	Vector3(8.87, 1.02, 22.18), Vector3(8.03, 1.02, 24.17),
	Vector3(7.75, 1.02, 26.21), Vector3(8.19, 1.02, 28.41),
	Vector3(8.33, 1.02, 30.29), Vector3(7.65, 1.02, 31.23),
	Vector3(5.81, 1.02, 32.18), Vector3(3.68, 1.02, 32.46),
	Vector3(1.88, 1.02, 32.10), Vector3(0.00, 1.02, 31.26),
	Vector3(-0.89, 1.02, 30.78)
]

var ruta_b: Array[Vector3] = [
	Vector3(-0.38, 1.02, 30.40), Vector3(1.86, 1.02, 30.60),
	Vector3(3.80, 1.02, 30.56), Vector3(6.43, 1.02, 29.67),
	Vector3(7.82, 1.02, 28.10), Vector3(8.16, 1.02, 26.41),
	Vector3(7.94, 1.02, 23.15), Vector3(8.77, 1.02, 21.61),
	Vector3(9.09, 1.02, 20.75), Vector3(9.76, 1.02, 18.69),
	Vector3(10.46, 1.02, 17.19), Vector3(11.47, 1.02, 16.08),
	Vector3(12.52, 1.02, 14.39), Vector3(12.95, 1.02, 11.62),
	Vector3(12.89, 1.02, 9.38), Vector3(12.64, 1.02, 8.07),
	Vector3(11.89, 1.02, 6.62), Vector3(11.02, 1.02, 5.61),
	Vector3(9.42, 1.02, 3.82), Vector3(7.96, 1.02, 1.92),
	Vector3(7.90, 1.02, 0.33), Vector3(8.92, 1.02, -2.15),
	Vector3(10.14, 1.02, -3.72), Vector3(11.48, 1.02, -4.97),
	Vector3(12.75, 1.02, -6.29), Vector3(13.83, 1.02, -8.98),
	Vector3(14.38, 1.02, -11.99), Vector3(14.10, 1.02, -13.80),
	Vector3(13.56, 1.02, -15.93), Vector3(13.21, 1.02, -17.49),
	Vector3(12.92, 1.02, -20.41), Vector3(12.84, 1.02, -22.14),
	Vector3(12.72, 1.02, -25.07), Vector3(12.63, 1.02, -27.09),
	Vector3(12.46, 1.02, -30.00), Vector3(12.03, 1.02, -32.92),
	Vector3(11.35, 1.02, -33.65), Vector3(9.33, 1.02, -33.94),
	Vector3(7.98, 1.02, -33.05), Vector3(7.65, 1.02, -31.68),
	Vector3(6.69, 1.02, -29.88), Vector3(5.22, 1.02, -28.08),
	Vector3(4.93, 1.02, -27.30), Vector3(5.30, 1.02, -25.38),
	Vector3(5.69, 1.02, -23.62), Vector3(4.98, 1.02, -22.69),
	Vector3(3.68, 1.02, -21.28), Vector3(3.34, 1.02, -20.26),
	Vector3(4.11, 1.02, -18.24), Vector3(4.43, 1.02, -16.88),
	Vector3(3.40, 1.02, -14.97), Vector3(1.32, 1.02, -13.04),
	Vector3(0.56, 1.02, -11.02), Vector3(0.60, 1.02, -9.28),
	Vector3(1.28, 1.02, -6.87), Vector3(1.72, 1.02, -4.44),
	Vector3(1.06, 1.02, -2.64), Vector3(0.15, 1.02, 0.55),
	Vector3(-0.35, 1.02, 2.58), Vector3(-1.58, 1.02, 4.00),
	Vector3(-2.32, 1.02, 4.55)
]

var gravedad = ProjectSettings.get_setting("physics/3d/default_gravity")
var jugador: Node3D = null
var puede_atacar = true


var ruta_actual: Array[Vector3] = []
var indice_ruta: int = 0
var usando_ruta_a: bool = true

var destino_objetivo: Vector3 = Vector3.ZERO
var idx_ruta_destino: int = -1
var tiene_destino: bool = false

var tiempo_juego: float = 0.0
var fase: int = 0
var golpes_dados: int = 0
var objetivo_completado: bool = false  # jugador completó algo en fase 1

var ultima_pos_jugador_vista: Vector3 = Vector3.ZERO
var zona_memoria: Vector3 = Vector3.ZERO
var tiene_memoria: bool = false
var timer_memoria: float = 0.0
var tiempo_sin_ver_jugador: float = 0.0
var puntos_memoria: Array[Vector3] = []
var indice_memoria: int = 0

var velocidad_actual: float = 3.3
var timer_cambio_vel: float = 0.0
var timer_pausa: float = 0.0

var ultima_pos_check: Vector3 = Vector3.ZERO
var timer_atasco: float = 0.0
var timer_atasco_directo: float = 0.0  # anti-atasco en modo directo

var objetivo_vigilancia: Vector3 = Vector3.ZERO
var vigilando: bool = false
var generadores_investigados: Array = []
var ultimo_generador_revisado = null

# Modo ataque directo — cuando detecta punto de ruta con visión al jugador
var ataque_directo: bool = false
var punto_ataque_directo: int = -1

@onready var audio_detectar = get_node_or_null("detectarJugador")
@onready var audio_monstruo = get_node_or_null("AudioMonstruo")
@onready var anim: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer

enum Estado { PATRULLANDO, PAUSADO, INVESTIGANDO, VIGILANDO, PERSIGUIENDO, ATACANDO, HUYENDO, MEMORIA }
var estado: Estado = Estado.PATRULLANDO

func _ready():
	add_to_group("enemigo")
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() > 0:
		jugador = jugadores[0]
	ultima_pos_check = global_position
	velocidad_actual = randf_range(2.8, 3.5)
	ruta_actual = ruta_a
	indice_ruta = _punto_mas_cercano(ruta_actual)
	_reproducir("Model|Idle")
	await get_tree().create_timer(randf_range(1.0, 3.0)).timeout
	estado = Estado.PATRULLANDO
	if area_ataque:
		area_ataque.body_entered.connect(_on_jugador_en_rango)

func _on_jugador_en_rango(body):
	if not body.is_in_group("jugador"):
		return
	if not puede_atacar:
		return
	if estado == Estado.ATACANDO:
		return
	if fase == 0:
		return
	_atacar()

func _physics_process(delta):
	var distancia_ruta = ruta_actual[_punto_mas_cercano(ruta_actual)].distance_to(global_position)

	if distancia_ruta > 4.0 and estado == Estado.PATRULLANDO:
		indice_ruta = _punto_mas_cercano(ruta_actual)

	tiempo_juego += delta
	_actualizar_fase()

	if not is_on_floor():
		velocity.y -= gravedad * delta
	else:
		velocity.y = 0.0

	# Velocidad variable impredecible
	timer_cambio_vel -= delta
	if timer_cambio_vel <= 0.0:
		timer_cambio_vel = randf_range(6.0, 18.0)
		if estado == Estado.PATRULLANDO or estado == Estado.VIGILANDO:
			velocidad_actual = randf_range(2.0, 4.5)
		if randf() < 0.08 and estado == Estado.PATRULLANDO:
			_entrar_pausa()

	# Anti atasco general
	if global_position.distance_to(ultima_pos_check) < 0.15:
		timer_atasco += delta
		if timer_atasco > 3.0:
			indice_ruta = (indice_ruta + 1) % ruta_actual.size()
			timer_atasco = 0.0
	else:
		timer_atasco = 0.0
	ultima_pos_check = global_position

	if tiene_memoria:
		timer_memoria -= delta
		if timer_memoria <= 0.0:
			tiene_memoria = false

	_detectar_sonidos()
	_actualizar_estado(delta)

	match estado:
		Estado.PATRULLANDO: _patrullar()
		Estado.PAUSADO: _esperar_pausa(delta)
		Estado.INVESTIGANDO: _mover_por_ruta_a_destino(velocidad_actual * 2.5, "Model|Run")
		Estado.VIGILANDO: _mover_por_ruta_a_destino(velocidad_actual, "Model|Walk")
		Estado.PERSIGUIENDO: _perseguir(delta)
		Estado.HUYENDO: _huir()
		Estado.MEMORIA: _mover_por_ruta_a_destino(velocidad_actual, "Model|Walk")
		Estado.ATACANDO:
			velocity.x = 0.0
			velocity.z = 0.0

	_actualizar_audio()
	if Engine.get_process_frames() % 60 == 0:
		pass
	move_and_slide()
# ─── FASES ─────────────────────────────────────────────────────────────────

func _actualizar_fase():
	if tiempo_juego < 10.0 and not objetivo_completado:
		fase = 0
	else:
		fase = 1

func _probabilidad_ataque() -> float:
	match fase:
		0:
			return 0.0
		1:
			return 1.0
	return 1.0

var timer_investigando: float = 0.0

func _ir_a_destino(destino: Vector3):

	timer_investigando = 0.0

	destino_objetivo = destino

	var origen = _punto_mas_cercano(ruta_actual)

	var destino_idx = _punto_ruta_mas_cercano_a(
		ruta_actual,
		destino
	)

	indice_ruta = origen
	idx_ruta_destino = destino_idx

	tiene_destino = true

func _mover_por_ruta_a_destino(vel: float, anim_nombre: String):
	if not tiene_destino: return

	timer_investigando += get_physics_process_delta_time()

	# Llegó al punto de ruta más cercano al destino — considerar llegada
	if indice_ruta == idx_ruta_destino:
		timer_investigando += get_physics_process_delta_time() * 2.0

	# Llegó o pasaron 4 segundos cerca — dar por llegado
	var dist_al_punto_destino = Vector2(
		global_position.x - ruta_actual[idx_ruta_destino].x,
		global_position.z - ruta_actual[idx_ruta_destino].z).length()
		
	if dist_al_punto_destino < 2.0 or timer_investigando > 4.0:
		if estado == Estado.MEMORIA and not puntos_memoria.is_empty():
			# Ir al siguiente punto de la zona de memoria
			indice_memoria = (indice_memoria + 1) % puntos_memoria.size()
			idx_ruta_destino = _punto_ruta_mas_cercano_a(ruta_actual, puntos_memoria[indice_memoria])
			indice_ruta = _punto_mas_cercano(ruta_actual)
			timer_investigando = 0.0
			# Si ya se acabó el tiempo de memoria, salir
			if not tiene_memoria:
				_al_llegar_destino()
		else:
			_al_llegar_destino()
		return

	# SIEMPRE por la ruta — nunca línea recta
	_avanzar_ruta_hacia(idx_ruta_destino, vel)
	_reproducir(anim_nombre)

func _avanzar_ruta_hacia(idx_destino: int, vel: float):
	if ruta_actual.is_empty(): return
	var objetivo_punto = ruta_actual[indice_ruta]
	var dist_punto = Vector2(global_position.x - objetivo_punto.x,
							 global_position.z - objetivo_punto.z).length()
	if dist_punto < 1.2:
		var pasos_adelante = (idx_destino - indice_ruta + ruta_actual.size()) % ruta_actual.size()
		var pasos_atras = (indice_ruta - idx_destino + ruta_actual.size()) % ruta_actual.size()
		if pasos_adelante == 0:
			return
		if pasos_adelante <= pasos_atras:
			indice_ruta = (indice_ruta + 1) % ruta_actual.size()
		else:
			indice_ruta = (indice_ruta - 1 + ruta_actual.size()) % ruta_actual.size()
		objetivo_punto = ruta_actual[indice_ruta]
	_mover_hacia(objetivo_punto, vel)

func _al_llegar_destino():
	tiene_destino = false
	ataque_directo = false

	match estado:
		Estado.INVESTIGANDO:
			ultimo_generador_revisado = destino_objetivo
			await get_tree().create_timer(3.0).timeout
			_decidir_vigilancia()
			estado = Estado.VIGILANDO
			_ir_a_destino(objetivo_vigilancia)

		Estado.VIGILANDO:
			# ✅ Desactivar vigilancia tras llegar, así la pausa
			# no vuelve a lanzar el mismo destino.
			vigilando = false
			_entrar_pausa()
			
		Estado.MEMORIA:
			# Si el jugador no es visible, no tiene sentido esperar más
			if not _puede_ver_jugador():
				# Cancelar memoria y volver a patrullar
				tiene_memoria = false
				timer_memoria = 0.0
				vigilando = false
				_reproducir("Model|Idle")
				_entrar_pausa()   # hará una pausa breve y luego seguirá su ruta
			else:
				# Si lo ve, se queda en idle esperando a que se acabe la memoria
				_reproducir("Model|Idle")
				if not tiene_memoria:
					estado = Estado.VIGILANDO if vigilando else Estado.PATRULLANDO
					if vigilando:
						_ir_a_destino(objetivo_vigilancia)
# ─── DETECCIÓN ─────────────────────────────────────────────────────────────

func _puede_ver_jugador() -> bool:
	if jugador == null or _jugador_escondido():
		return false
	var dist = global_position.distance_to(jugador.global_position)
	if dist > rango_vision:
		return false
	var dir = (jugador.global_position - global_position)
	dir.y = 0
	var frente = -global_transform.basis.z
	frente.y = 0
	var angle = rad_to_deg(frente.normalized().angle_to(dir.normalized()))
	if angle > angulo_vision / 2.0:
		return false
	var espacio = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * 1.8,
		jugador.global_position + Vector3.UP * 1.8
	)
	query.exclude = [self]
	var res = espacio.intersect_ray(query)
	if res and res.collider != jugador:
		return false
	return true

func _hay_vision_directa(desde: Vector3, hasta: Vector3) -> bool:
	var espacio = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		desde + Vector3.UP * 1.8,
		hasta + Vector3.UP * 1.8
	)
	query.exclude = [self]
	var res = espacio.intersect_ray(query)
	if res and jugador and res.collider == jugador: return true
	if not res: return true
	return false

func _jugador_escondido() -> bool:
	return jugador != null and jugador.get("escondido") == true

func _detectar_sonidos():
	if jugador == null: return
	for gen in get_tree().get_nodes_in_group("generadores"):
		if gen.get("encendido") == true and not generadores_investigados.has(gen):
			var d = global_position.distance_to(gen.global_position)
			if d < 35.0 and estado != Estado.PERSIGUIENDO and estado != Estado.ATACANDO:
				generadores_investigados.append(gen)
				# Marcar objetivo completado si está en fase 1
				if fase == 1:
					objetivo_completado = true
				# Solo se activa investigación; la vigilancia se decide al terminar
				estado = Estado.INVESTIGANDO
				_ir_a_destino(gen.global_position)
				# No se llama a _decidir_vigilancia aquí
				# (se hará en _al_llegar_destino)
				break  # Una sola investigación a la vez

func escuchar_puerta(pos: Vector3):
	if estado == Estado.PERSIGUIENDO or estado == Estado.ATACANDO: return
	if global_position.distance_to(pos) < 30.0:
		if fase == 1:
			objetivo_completado = true
		estado = Estado.INVESTIGANDO
		_ir_a_destino(pos)

# Llamar esto desde puertaLlave.gd cuando se abre
func notificar_objetivo_completado():
	if fase == 1:
		objetivo_completado = true

# ─── VIGILANCIA ────────────────────────────────────────────────────────────

func _decidir_vigilancia():
	var gen1_on = false
	var gen2_on = false
	for gen in get_tree().get_nodes_in_group("generadores"):
		if gen.get("id_generador") == 1 and gen.get("encendido"): gen1_on = true
		if gen.get("id_generador") == 2 and gen.get("encendido"): gen2_on = true

	if gen1_on and not gen2_on:
		objetivo_vigilancia = pos_generador2
	elif gen2_on and not gen1_on:
		objetivo_vigilancia = pos_generador1
	else:
		objetivo_vigilancia = pos_llave if randf() < 0.5 else pos_galon

	vigilando = true

# ─── ESTADOS ───────────────────────────────────────────────────────────────

func _actualizar_estado(delta):

	# Durante ataque no cambiar estados
	if estado == Estado.ATACANDO:
		return

	var ve = _puede_ver_jugador()

	# ─────────────────────────────
	# VE AL JUGADOR
	# ─────────────────────────────
	if ve:

		tiempo_sin_ver_jugador = 0.0
		ultima_pos_jugador_vista = jugador.global_position

		# Si estaba investigando algo lo cancela
		tiene_destino = false

		# FASE 0
		# Acecha pero no golpea
		if fase == 0:

			if estado != Estado.PERSIGUIENDO:

				estado = Estado.PERSIGUIENDO

				velocidad_actual = randf_range(
					velocidad_caminar * 1.1,
					velocidad_caminar * 1.4
				)

				if audio_detectar and not audio_detectar.playing:
					audio_detectar.play()

			return

		# FASE AGRESIVA
		if estado != Estado.PERSIGUIENDO:
			_entrar_persecucion()

		return

	# ─────────────────────────────
	# NO LO VE
	# ─────────────────────────────
	if estado == Estado.PERSIGUIENDO:

		tiempo_sin_ver_jugador += delta

		# Dale tiempo antes de rendirse
		if tiempo_sin_ver_jugador < 3.0:
			return
		zona_memoria = ultima_pos_jugador_vista
		tiene_memoria = true
		timer_memoria = randf_range(25.0, 40.0)
		_recolocar_en_ruta()
		estado = Estado.MEMORIA
		# Generar lista de puntos cercanos a la última posición vista (radio 15 m)
		puntos_memoria.clear()
		for punto in ruta_actual:
			if punto.distance_to(zona_memoria) < 15.0:
				puntos_memoria.append(punto)
		if puntos_memoria.is_empty():
			# Si no hay ninguno, usa el punto más cercano
			puntos_memoria.append(ruta_actual[_punto_ruta_mas_cercano_a(ruta_actual, zona_memoria)])
		indice_memoria = 0
		_ir_a_destino(puntos_memoria[0])
		return

	# ─────────────────────────────
	# MEMORIA TERMINADA
	# ─────────────────────────────
	if estado == Estado.MEMORIA:

		if not tiene_memoria:

			if vigilando:

				estado = Estado.VIGILANDO

				_ir_a_destino(
					objetivo_vigilancia
				)

			else:

				estado = Estado.PATRULLANDO

func _entrar_persecucion():
	estado = Estado.PERSIGUIENDO
	velocidad_actual = randf_range(velocidad_correr * 0.85, velocidad_correr * 1.05)
	vigilando = false
	tiene_destino = false
	ataque_directo = false
	if audio_detectar and not audio_detectar.playing:
		audio_detectar.play()

func _entrar_huyendo():
	estado = Estado.HUYENDO
	velocidad_actual = randf_range(velocidad_correr, velocidad_correr * 1.15)
	tiene_destino = false
	ataque_directo = false
	if audio_detectar and audio_detectar.playing:
		audio_detectar.stop()
	if audio_monstruo and audio_monstruo.playing:
		audio_monstruo.stop()
	# Punto de ruta en dirección opuesta al jugador
	if jugador:
		var dir_escape = (global_position - jugador.global_position)
		dir_escape.y = 0
		if dir_escape.length() > 0.1: dir_escape = dir_escape.normalized()
		var mejor = indice_ruta
		var mejor_dot = -999.0
		for i in range(ruta_actual.size()):
			var dp = (ruta_actual[i] - global_position)
			dp.y = 0
			if dp.length() < 0.1: continue
			var d = dir_escape.dot(dp.normalized())
			if d > mejor_dot:
				mejor_dot = d
				mejor = i
		var punto_escape = ruta_actual[mejor]
		_ir_a_destino(punto_escape)
		tiene_destino = true
		idx_ruta_destino = mejor

func _entrar_pausa():
	estado = Estado.PAUSADO
	timer_pausa = randf_range(2.0, 7.0)
	velocity.x = 0.0
	velocity.z = 0.0
	_reproducir("Model|Idle")

# ─── COMPORTAMIENTOS ───────────────────────────────────────────────────────

func _patrullar():
	var objetivo = ruta_actual[indice_ruta]
	var dist_xz = Vector2(global_position.x - objetivo.x, global_position.z - objetivo.z).length()
	if dist_xz < 1.2:
		# Cambia al siguiente punto de la ruta
		indice_ruta = (indice_ruta + 1) % ruta_actual.size()
		if indice_ruta == 0:
			_cambiar_ruta()
		
		# IMPREDECIBILIDAD: 15% de probabilidad de ir a vigilar un objetivo
		if randf() < 0.15:
			objetivo_vigilancia = _objetivo_aleatorio_proteger()
			vigilando = true
			_ir_a_destino(objetivo_vigilancia)
			estado = Estado.VIGILANDO
		return
	
	_mover_hacia(objetivo, velocidad_actual)
	_reproducir("Model|Walk")
func _esperar_pausa(delta):
	velocity.x = 0.0
	velocity.z = 0.0
	timer_pausa -= delta
	if timer_pausa <= 0.0:
		estado = Estado.VIGILANDO if vigilando else Estado.PATRULLANDO
		if vigilando: _ir_a_destino(objetivo_vigilancia)
		velocidad_actual = randf_range(2.5, 4.0)

func _perseguir(delta):
	if jugador == null:
		return

	# ─── JUGADOR ESCONDIDO ───
	if _jugador_escondido():
		if estado == Estado.PERSIGUIENDO:
			velocity = Vector3.ZERO
			tiene_destino = false
			ataque_directo = false
			_reproducir("Model|Idle")
			if audio_monstruo and audio_monstruo.playing:
				audio_monstruo.stop()
			if audio_detectar and audio_detectar.playing:
				audio_detectar.stop()
			estado = Estado.PAUSADO
			timer_pausa = randf_range(3.0, 6.0)
		return

	var dist = global_position.distance_to(jugador.global_position)

	# FASE 0 – acecho sin golpear
	if fase == 0:
		var punto_jugador = _punto_ruta_mas_cercano_a(ruta_actual, jugador.global_position)
		_avanzar_ruta_hacia(punto_jugador, velocidad_actual * 1.2)
		_reproducir("Model|Walk")
		if dist < 6.0:
			_mirar_a(jugador.global_position)
			if audio_detectar and not audio_detectar.playing:
				audio_detectar.play()
		return

	# FASE 1 – persecución agresiva
	if dist <= rango_ataque:
		velocity.x = 0
		velocity.z = 0
		_mirar_a(jugador.global_position)
		if puede_atacar:
			_atacar()
		return

	var punto_jugador = _punto_ruta_mas_cercano_a(ruta_actual, jugador.global_position)
	var dist_punto = Vector2(
		global_position.x - ruta_actual[punto_jugador].x,
		global_position.z - ruta_actual[punto_jugador].z).length()

	# Ataque directo si está muy cerca y con visión clara
	if dist < 5.0 and _hay_vision_directa(global_position, jugador.global_position):
		_mover_hacia(jugador.global_position, velocidad_actual * 1.3)
		_reproducir("Model|Run")
		if global_position.distance_to(ultima_pos_check) < 0.15:
			timer_atasco_directo += delta
			if timer_atasco_directo > 2.0:
				ataque_directo = false
				timer_atasco_directo = 0.0
		else:
			timer_atasco_directo = 0.0
		return

	# Sprint final cuando ya está en el punto de ruta más cercano al jugador
	if dist_punto < 3.0 and _hay_vision_directa(global_position, jugador.global_position):
		_mover_hacia(jugador.global_position, velocidad_actual * 1.25)
		_reproducir("Model|Run")
		return

	# Movimiento normal por la ruta hacia el jugador
	_avanzar_ruta_hacia(punto_jugador, velocidad_actual)
	_reproducir("Model|Run")


func _buscar_punto_ruta_con_vision() -> int:
	if jugador == null: return -1
	# Buscar el punto de ruta más cercano al jugador que tenga visión directa
	var mejor_idx = -1
	var menor_dist = 9999.0
	for i in range(ruta_actual.size()):
		var d = ruta_actual[i].distance_to(jugador.global_position)
		if d < menor_dist and d < 12.0:
			if _hay_vision_directa(ruta_actual[i], jugador.global_position):
				menor_dist = d
				mejor_idx = i
	return mejor_idx

func _huir():
	if idx_ruta_destino == -1:
		velocity.x = 0
		velocity.z = 0
		estado = Estado.PATRULLANDO
		return
	_avanzar_ruta_hacia(idx_ruta_destino, velocidad_actual)
	_reproducir("Model|Run")
	if jugador and global_position.distance_to(jugador.global_position) > 14.0:
		velocidad_actual = randf_range(2.5, 3.8)
		if audio_detectar and audio_detectar.playing: audio_detectar.stop()
		estado = Estado.PATRULLANDO
		tiene_destino = false
		idx_ruta_destino = -1
# ─── ATAQUE ────────────────────────────────────────────────────────────────

func _atacar():
	if _jugador_escondido(): return 
	puede_atacar = false
	estado = Estado.ATACANDO
	ataque_directo = false
	_reproducir("Model|Attack")
	if jugador and jugador.has_method("recibir_golpe"):
		jugador.recibir_golpe()
	golpes_dados += 1
	await get_tree().create_timer(0.6).timeout
	if not is_inside_tree(): return

	if golpes_dados >= 3:
		if jugador and jugador.has_method("morir"):
			jugador.morir()
		return

	# Regresar a ruta y huir
	indice_ruta = _punto_mas_cercano(ruta_actual)
	estado = Estado.PERSIGUIENDO  # sigue persiguiendo en vez de huir
	await get_tree().create_timer(2.0).timeout  # ← 2 segundos entre golpes
	if not is_inside_tree(): return
	puede_atacar = true

# ─── AUDIO ─────────────────────────────────────────────────────────────────

func _actualizar_audio():

	if jugador == null or audio_monstruo == null:
		return

	if estado == Estado.PERSIGUIENDO and fase == 1:

		if not audio_monstruo.playing:
			audio_monstruo.play()

	else:

		if audio_monstruo.playing:
			audio_monstruo.stop()

# ─── RUTA ──────────────────────────────────────────────────────────────────

func _cambiar_ruta():
	usando_ruta_a = !usando_ruta_a
	ruta_actual = ruta_a if usando_ruta_a else ruta_b
	indice_ruta = _punto_mas_cercano(ruta_actual)

func _punto_mas_cercano(ruta: Array[Vector3]) -> int:
	var mejor = 0
	var menor_dist = 9999.0
	for i in range(ruta.size()):
		var d = Vector2(global_position.x - ruta[i].x, global_position.z - ruta[i].z).length()
		if d < menor_dist:
			menor_dist = d
			mejor = i
	return mejor

func _punto_ruta_mas_cercano_a(ruta: Array[Vector3], pos: Vector3) -> int:
	var mejor = 0
	var menor_dist = 9999.0
	for i in range(ruta.size()):
		var d = Vector2(pos.x - ruta[i].x, pos.z - ruta[i].z).length()
		if d < menor_dist:
			menor_dist = d
			mejor = i
	return mejor

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

func _objetivo_aleatorio_proteger() -> Vector3:
	# Objetos importantes por los que el monstruo puede desviarse
	var opciones = [
		pos_llave,
		pos_galon,
		pos_generador1,
		pos_generador2
	]
	# Excluye el que ya está siendo vigilado si coincide
	var seleccion = opciones[randi() % opciones.size()]
	return seleccion

func _recolocar_en_ruta():
	var idx = _punto_mas_cercano(ruta_actual)
	var punto = ruta_actual[idx]
	if global_position.distance_to(punto) > 4.0:
		global_position = punto
		indice_ruta = idx
