extends CharacterBody3D

var golpes = 0
var golpes_maximos = 3
var muerto = false
var label_piso: Label
var video_player_muerte: VideoStreamPlayer
var audio_player_muerte: AudioStreamPlayer

var velocidad = 10
var velocidad_con_carga = 5
var gravedad = 9.8
var sensibilidad_mouse = 0.002

var cama_posicion = Vector3.ZERO
var mirando_atras = false
var rotacion_y_guardada = 0.0
enum TipoEscondite { NINGUNO, CAMA, CLOSET, BASURA }
var tipo_escondite_cercano: TipoEscondite = TipoEscondite.NINGUNO
var cerca_de_escaleras = false
var escondido = false
var puede_esconderse = false
var posicion_normal = Vector3(0, 0.7, 0)
var bloqueado = false

var linterna_encendida = true
var overlay_dano: ColorRect

var puerta_cercana = null
var objeto_cercano = null
var objeto_en_mano = null
var texto_interaccion: Label
var label_objeto_en_mano: Label

var stamina = 100.0
var stamina_maxima = 100.0
var gasto_stamina = 25.0
var recuperacion_stamina = 75.0
var puede_correr = true
var timer_recuperacion = 0.0
var delay_recuperacion = 3.0
var recuperando = false

var tiempo_temblor = 0.0
var hud: CanvasLayer

# Precargar cinematica al inicio
var cinematica_muerte = load("res://cinematic/jumpscare-perron2.ogv")
var audio_muerte = load("res://sonidos/jumpscare dos.mp3")
var cinematica_muerte_piso2 = load("res://cinematic/JumpScarepiso2.ogv")
var audio_muerte_piso2 = load("res://sonidosOrganizados/monstruoPiso2/jumpscare2.mp3")

@onready var camara = $Camera3D
@onready var linterna = $Camera3D/SpotLight3D

func _ready():
	add_to_group("jugador")
		# Si hay un punto de spawn guardado, teletransportarse allí
	if PlayerSpawn.spawn_position != Vector3.ZERO:
		global_position = PlayerSpawn.spawn_position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crear_hud()
	_actualizar_label_piso()  # ← Añadir esto
	_reproducir_audio_inicio()
		# Precargar reproductores de cinemática de muerte
	video_player_muerte = VideoStreamPlayer.new()
	video_player_muerte.expand = true
	video_player_muerte.set_anchors_preset(Control.PRESET_FULL_RECT)
	audio_player_muerte = AudioStreamPlayer.new()

func _reproducir_audio_inicio():
	await get_tree().create_timer(15.0).timeout
	if not is_inside_tree(): return
	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://sonidos/empiezas a moverte.mp3")
	get_tree().current_scene.add_child(audio)
	audio.play()
	await audio.finished
	audio.queue_free()

# ─── HUD ───────────────────────────────────────────────────────────────────

func crear_hud():
	hud = CanvasLayer.new()
	add_child(hud)

	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.6)
	fondo.size = Vector2(204, 18)
	fondo.position = Vector2(20, 20)
	hud.add_child(fondo)

	var barra = ColorRect.new()
	barra.name = "BarraStamina"
	barra.color = Color(0.2, 0.8, 0.3)
	barra.size = Vector2(200, 14)
	barra.position = Vector2(22, 22)
	hud.add_child(barra)

	label_objeto_en_mano = Label.new()
	label_objeto_en_mano.name = "LabelObjeto"
	label_objeto_en_mano.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_objeto_en_mano.add_theme_font_size_override("font_size", 20)
	label_objeto_en_mano.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	label_objeto_en_mano.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	label_objeto_en_mano.position.y = -60
	label_objeto_en_mano.visible = false
	hud.add_child(label_objeto_en_mano)

	texto_interaccion = Label.new()
	texto_interaccion.name = "TextoInteraccion"
	texto_interaccion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto_interaccion.add_theme_font_size_override("font_size", 18)
	texto_interaccion.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	texto_interaccion.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	texto_interaccion.position.y = -100
	texto_interaccion.position.x = -200
	texto_interaccion.size.x = 400
	texto_interaccion.visible = false
	hud.add_child(texto_interaccion)

	overlay_dano = ColorRect.new()
	overlay_dano.color = Color(1, 0, 0, 0.0)
	overlay_dano.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_dano.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(overlay_dano)
	label_piso = Label.new()
	label_piso.name = "LabelPiso"
	label_piso.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label_piso.add_theme_font_size_override("font_size", 16)
	label_piso.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	label_piso.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	label_piso.position = Vector2(-20, 50)
	hud.add_child(label_piso)
	_actualizar_label_piso()
var mostrando_mensaje = false
func _actualizar_label_piso():
	var ruta = get_tree().current_scene.scene_file_path
	if ruta.ends_with("sotano.tscn"):
		label_piso.text = "Sótano - Piso 1"
	elif ruta.ends_with("escenaSegundoPiso.tscn"):
		label_piso.text = "Segundo Piso"
	else:
		label_piso.text = "Desconocido"

func actualizar_hud():
	var barra = hud.get_node("BarraStamina")
	var porcentaje = stamina / stamina_maxima
	barra.size.x = 200 * porcentaje

	if porcentaje > 0.5:
		barra.color = Color(0.2, 0.8, 0.3)
	elif porcentaje > 0.25:
		barra.color = Color(0.9, 0.7, 0.1)
	else:
		barra.color = Color(0.8, 0.1, 0.1)

	if recuperando:
		barra.color.a = 0.5 + sin(Time.get_ticks_msec() * 0.005) * 0.5
	else:
		barra.color.a = 1.0

	var hint = ""
	if objeto_cercano != null and objeto_en_mano == null:
		hint = "[R] Recoger " + objeto_cercano.nombre_display
	elif objeto_en_mano != null:
		hint = "[R] Soltar/Depositar " + objeto_en_mano.nombre_display
	elif puerta_cercana != null:
		hint = "[E] Abrir puerta"
	elif puede_esconderse and not escondido:
		match tipo_escondite_cercano:
			TipoEscondite.CAMA:   hint = "[E] Esconderse (cama)"
			TipoEscondite.CLOSET: hint = "[E] Esconderse (closet)"
			TipoEscondite.BASURA: hint = "[E] Esconderse (basura)"

	elif escondido:
		hint = "[E] Salir del escondite"

	if not cerca_de_escaleras and not cerca_de_cableado and not mostrando_mensaje:
		texto_interaccion.text = hint
		texto_interaccion.visible = hint != ""

	if objeto_en_mano != null:
		label_objeto_en_mano.text = "Cargando: " + objeto_en_mano.nombre_display
		label_objeto_en_mano.visible = true
	else:
		label_objeto_en_mano.visible = false

# ─── INPUT ─────────────────────────────────────────────────────────────────
var cerca_de_cableado = false
func _input(event):
	if bloqueado:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_E and escondido:
				_interactuar_escondite()
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensibilidad_mouse)
		camara.rotate_x(-event.relative.y * sensibilidad_mouse)
		camara.rotation.x = clamp(camara.rotation.x, -1.2, 1.2)

	if event is InputEventKey and not event.echo:
		if event.keycode == KEY_Q:
			if not escondido and not bloqueado:
				if event.pressed:
					_voltear_atras(true)
				else:
					_voltear_atras(false)

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			mostrar_menu_pausa()
		elif event.keycode == KEY_F:
			linterna_encendida = !linterna_encendida
			linterna.visible = linterna_encendida
		elif event.keycode == KEY_E:
			_interactuar_escondite()
		elif event.keycode == KEY_R:
			_interactuar_objeto()
		elif event.keycode == KEY_SPACE:
			print("Posición del jugador: ", global_position)
		elif event.keycode == KEY_Z:
			_usar_escaleras()
		elif event.keycode == KEY_C:
			pass

# ─── INTERACCIÓN ───────────────────────────────────────────────────────────

var movimiento_bloqueado = false


func _voltear_atras(activar: bool):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if activar:
		tween.tween_property(camara, "rotation:y", deg_to_rad(175), 0.25)
	else:
		tween.tween_property(camara, "rotation:y", 0.0, 0.2)
# E — escondites y puertas
func _interactuar_escondite():
	if puerta_cercana != null:
		if puerta_cercana.has_method("interactuar"):
			puerta_cercana.interactuar()
		return
	if puede_esconderse or escondido:
		match tipo_escondite_cercano:
			TipoEscondite.CAMA:   _toggle_escondido_cama()
			TipoEscondite.CLOSET: _toggle_escondido_closet()
			TipoEscondite.BASURA: _toggle_escondido_closet()

func _toggle_voltear_atras():
	mirando_atras = !mirando_atras
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if mirando_atras:
		rotacion_y_guardada = rotation.y
		tween.tween_property(camara, "rotation:y", deg_to_rad(175), 0.25)
	else:
		tween.tween_property(camara, "rotation:y", 0.0, 0.2)

func _usar_escaleras():
	if not cerca_de_escaleras:
		return

	bloqueado = true

	# Fade a negro
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var capa = CanvasLayer.new()
	capa.layer = 99
	add_child(capa)
	capa.add_child(fade)

	var tween = create_tween()
	tween.tween_property(fade, "color", Color(0, 0, 0, 1), 0.6)
	await tween.finished

	# Detectar escena actual por archivo
	var ruta = get_tree().current_scene.scene_file_path

	print("Escena actual:", ruta)

	if ruta.ends_with("escenaSegundoPiso.tscn"):
		PlayerSpawn.set_spawn(Vector3(-13.17891, 1.019905, -34.0269))
		get_tree().change_scene_to_file("res://sotano.tscn")

	elif ruta.ends_with("sotano.tscn"):
		PlayerSpawn.set_spawn(Vector3(0.954108, 9.765799, 5.41836))
		get_tree().change_scene_to_file("res://escenaSegundoPiso.tscn")

	else:
		print("ERROR: Escena no reconocida")
		bloqueado = false
		capa.queue_free()

# R — recoger, soltar y depositar objetos
func _interactuar_objeto():
	if objeto_en_mano != null:
		# Intentar depositar primero
		var depositado = await _intentar_depositar()
		if not depositado:
			_soltar_objeto()
		return
	if objeto_cercano != null:
		_agarrar_objeto(objeto_cercano)
		return

func _toggle_escondido_cama():
	escondido = !escondido
	movimiento_bloqueado = escondido
	# Soltar objeto al esconderse
	if escondido and objeto_en_mano != null:
		_soltar_objeto()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if escondido:
		tween.tween_property(camara, "position", Vector3(0, 1.8, 2.8), 0.5)
		tween.parallel().tween_property(camara, "rotation", Vector3(deg_to_rad(-18), 0, 0), 0.5)
	else:
		tween.tween_property(camara, "position", posicion_normal, 0.5)
		tween.parallel().tween_property(camara, "rotation", Vector3(0, 0, 0), 0.5)

func _toggle_escondido_closet():
	escondido = !escondido
	movimiento_bloqueado = escondido
	# Soltar objeto al esconderse
	if escondido and objeto_en_mano != null:
		_soltar_objeto()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if escondido:
		tween.tween_property(camara, "position", Vector3(0, 1.8, 2.8), 0.5)
		tween.parallel().tween_property(camara, "rotation", Vector3(deg_to_rad(-18), 0, 0), 0.5)
	else:
		tween.tween_property(camara, "position", posicion_normal, 0.5)
		tween.parallel().tween_property(camara, "rotation", Vector3(0, 0, 0), 0.5)

func _agarrar_objeto(obj):
	objeto_en_mano = obj
	obj.agarrar(camara)

func _soltar_objeto():
	if objeto_en_mano == null: return
	objeto_en_mano.soltar()
	objeto_en_mano = null

func _intentar_depositar() -> bool:
	var nodos_cercanos = []
	for grupo in ["generadores", "puertas_llave"]:
		nodos_cercanos += get_tree().get_nodes_in_group(grupo)
	for nodo in nodos_cercanos:
		var dist = global_position.distance_to(nodo.global_position)
		if dist < 2.5 and nodo.has_method("recibir_objeto"):
			var resultado = await nodo.recibir_objeto(objeto_en_mano)
			if resultado:
				objeto_en_mano = null
				return true
	return false

func registrar_objeto_cercano(obj):
	objeto_cercano = obj

func limpiar_objeto_cercano(obj):
	if objeto_cercano == obj:
		objeto_cercano = null

func mostrar_mensaje_temporal(texto: String, duracion: float = 3.0):
	mostrando_mensaje = true
	texto_interaccion.text = texto
	texto_interaccion.visible = true
	await get_tree().create_timer(duracion).timeout
	if is_inside_tree():
		texto_interaccion.visible = false
	mostrando_mensaje = false

# ─── FÍSICA ────────────────────────────────────────────────────────────────

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravedad * delta

	if bloqueado or movimiento_bloqueado:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	var corriendo = Input.is_key_pressed(KEY_SHIFT) and puede_correr and stamina > 0
	var vel_base = velocidad_con_carga if (objeto_en_mano != null and objeto_en_mano.es_pesado) else velocidad
	@warning_ignore("incompatible_ternary")
	var vel = vel_base * 1.6 if corriendo else vel_base

	if corriendo:
		stamina -= gasto_stamina * delta
		stamina = max(stamina, 0)
		timer_recuperacion = 0.0
		recuperando = false
		if stamina == 0:
			puede_correr = false
	else:
		if stamina < stamina_maxima:
			timer_recuperacion += delta
			if timer_recuperacion >= delay_recuperacion:
				recuperando = true
				stamina += recuperacion_stamina * delta
				stamina = min(stamina, stamina_maxima)
		if stamina >= stamina_maxima:
			recuperando = false
			puede_correr = true
		if stamina > 30:
			puede_correr = true

	actualizar_hud()

	var direccion = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): direccion -= transform.basis.z
	if Input.is_key_pressed(KEY_S): direccion += transform.basis.z
	if Input.is_key_pressed(KEY_A): direccion -= transform.basis.x
	if Input.is_key_pressed(KEY_D): direccion += transform.basis.x
	if direccion != Vector3.ZERO:
		direccion = direccion.normalized()

	if corriendo and direccion != Vector3.ZERO:
		tiempo_temblor += delta * 12.0
		camara.rotation.z = sin(tiempo_temblor) * 0.04
		camara.rotation.x += sin(tiempo_temblor * 1.3) * 0.006
	else:
		tiempo_temblor = 0.0
		camara.rotation.z = lerp(camara.rotation.z, 0.0, delta * 10.0)

	velocity.x = direccion.x * vel
	velocity.z = direccion.z * vel
	move_and_slide()

# ─── DAÑO / MUERTE ─────────────────────────────────────────────────────────

func recibir_golpe():
	if muerto: return
	golpes += 1
	if overlay_dano != null:
		overlay_dano.color = Color(1, 0, 0, 0.45)
		var tween = create_tween()
		tween.tween_property(overlay_dano, "color", Color(1, 0, 0, 0.0), 0.35)
	if golpes >= golpes_maximos:
		morir()
	else:
		_adrenalina()  # ← agrega esto

func _adrenalina():
	mostrar_mensaje_temporal("¡Adrenalina activada!", 2.0)
	var stamina_original = stamina_maxima
	puede_correr = true
	stamina = stamina_maxima
	# Desactivar gasto de stamina por 3 segundos
	var gasto_original = gasto_stamina
	gasto_stamina = 0.0
	await get_tree().create_timer(3.0).timeout
	if is_inside_tree():
		gasto_stamina = gasto_original

func morir():
	if muerto: return
	muerto = true
	bloqueado = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Silenciar todo el juego
	for hijo in get_tree().get_nodes_in_group("enemigo"):
		if hijo.has_node("detectarJugador"):
			hijo.get_node("detectarJugador").stop()
		if hijo.has_node("AudioMonstruo"):
			hijo.get_node("AudioMonstruo").stop()
	var nodo_fondo = get_tree().current_scene.get_node_or_null("sonidoFondo")
	if nodo_fondo: nodo_fondo.stop()
	_reproducir_cinematica_muerte()

func _reproducir_cinematica_muerte():
	# Silenciar loop del monstruo
	for e in get_tree().get_nodes_in_group("enemigo"):
		for nombre in ["detectarJugador", "AudioMonstruo"]:
			var a = e.get_node_or_null(nombre)
			if a: a.stop()
	var fondo_nodo = get_tree().current_scene.get_node_or_null("sonidoFondo")
	if fondo_nodo: fondo_nodo.stop()

	# Detectar piso actual
	var ruta = get_tree().current_scene.scene_file_path
	var video_stream
	var audio_stream
	
	if ruta.ends_with("escenaSegundoPiso.tscn"):
		video_stream = cinematica_muerte_piso2
		audio_stream = audio_muerte_piso2
	else:
		video_stream = cinematica_muerte
		audio_stream = audio_muerte

	var capa = CanvasLayer.new()
	capa.layer = 10
	add_child(capa)

	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 1)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_child(fondo)

	if video_stream == null:
		mostrar_menu_muerte()
		return

	# Usar reproductores precargados
	video_player_muerte.stream = video_stream
	audio_player_muerte.stream = audio_stream
	
	# Quitar de su padre anterior si lo tiene
	if video_player_muerte.get_parent():
		video_player_muerte.get_parent().remove_child(video_player_muerte)
	if audio_player_muerte.get_parent():
		audio_player_muerte.get_parent().remove_child(audio_player_muerte)
	
	capa.add_child(video_player_muerte)
	capa.add_child(audio_player_muerte)

	video_player_muerte.play()
	audio_player_muerte.play()

	# Temporizador de seguridad
	var tiempo_limite = 5.0
	var timer = get_tree().create_timer(tiempo_limite)
	var audio_terminado = false

	if audio_player_muerte.stream:
		@warning_ignore("confusable_capture_reassignment")
		audio_player_muerte.finished.connect(func(): audio_terminado = true)

	while not audio_terminado and timer.time_left > 0:
		await get_tree().process_frame

	if not is_inside_tree(): return
	video_player_muerte.stop()
	if audio_player_muerte.playing: audio_player_muerte.stop()
	
	# Quitar reproductores de la capa (se reutilizarán)
	if video_player_muerte.get_parent():
		video_player_muerte.get_parent().remove_child(video_player_muerte)
	if audio_player_muerte.get_parent():
		audio_player_muerte.get_parent().remove_child(audio_player_muerte)
	
	capa.queue_free()
	await get_tree().process_frame
	mostrar_menu_muerte()

func mostrar_menu_muerte():
	print("MOSTRANDO MENU MUERTE")
	get_tree().paused = true
	AudioServer.set_bus_volume_db(0, 0)

	var menu = CanvasLayer.new()
	menu.name = "MenuMuerte"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(menu)

	var video = VideoStreamPlayer.new()
	video.stream = load("res://cinematic/MenuMuerte.ogv")
	video.expand = true
	video.set_anchors_preset(Control.PRESET_FULL_RECT)
	video.process_mode = Node.PROCESS_MODE_ALWAYS
	menu.add_child(video)
	video.play()

	var audio = AudioStreamPlayer.new()
	audio.stream = load("res://sonidos/sonidoMenuMuerte.mp3")
	audio.volume_db = 0.0
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	menu.add_child(audio)
	audio.play()

	var titulo = Label.new()
	titulo.text = "HAS MUERTO"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 60)
	titulo.add_theme_color_override("font_color", Color(0.9, 0, 0))
	titulo.set_anchors_preset(Control.PRESET_TOP_WIDE)
	titulo.position.y = 150
	menu.add_child(titulo)

	var btn_reiniciar = Button.new()
	btn_reiniciar.text = "REINICIAR"
	btn_reiniciar.size = Vector2(300, 60)
	btn_reiniciar.position = Vector2(get_viewport().size.x / 2 - 150, 330)
	btn_reiniciar.process_mode = Node.PROCESS_MODE_ALWAYS
	menu.add_child(btn_reiniciar)
	btn_reiniciar.pressed.connect(_reiniciar_juego)

	var btn_salir = Button.new()
	btn_salir.text = "SALIR"
	btn_salir.size = Vector2(300, 60)
	btn_salir.position = Vector2(get_viewport().size.x / 2 - 150, 410)
	btn_salir.process_mode = Node.PROCESS_MODE_ALWAYS
	menu.add_child(btn_salir)
	btn_salir.pressed.connect(func(): get_tree().quit())

func _reiniciar_juego():
	get_tree().paused = false
	
	# Resetear GameState (progreso principal)
	GameState.reset()
	
	# Resetear estado del segundo piso
	GameState.cables_reparados = false
	var mono = get_tree().get_first_node_in_group("enemigo_cables")
	if mono:
		mono.global_position = Vector3(200, 200, 200)
		mono.activo = false
	
	# Punto de inicio real del sótano
	PlayerSpawn.set_spawn(Vector3(-7.2, 3, 0.5349))
	
	get_tree().change_scene_to_file("res://sotano.tscn")

func mostrar_menu_pausa():
	if has_node("MenuPausa"):
		get_node("MenuPausa").queue_free()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false
		return

	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var menu = CanvasLayer.new()
	menu.name = "MenuPausa"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(menu)

	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.85)
	fondo.size = get_viewport().get_visible_rect().size
	menu.add_child(fondo)

	var titulo = Label.new()
	titulo.text = "PAUSA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 56)
	titulo.add_theme_color_override("font_color", Color.WHITE)
	titulo.set_anchors_preset(Control.PRESET_TOP_WIDE)
	titulo.position.y = 110
	menu.add_child(titulo)

	for dato in [["VOLVER", 300], ["REINICIAR", 380], ["SALIR", 460]]:
		var btn = Button.new()
		btn.text = dato[0]
		btn.size = Vector2(300, 60)
		btn.position = Vector2(get_viewport().size.x / 2 - 150, dato[1])
		menu.add_child(btn)

		if dato[0] == "VOLVER":
			btn.pressed.connect(func():
				menu.queue_free()
				get_tree().paused = false
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			)

		elif dato[0] == "REINICIAR":
			btn.pressed.connect(_reiniciar_juego)

		else:
			btn.pressed.connect(func():
				get_tree().quit()
			)

func mostrar_mensaje_escalera(mostrar: bool):
	if mostrar:
		var ruta = get_tree().current_scene.scene_file_path

		if ruta.ends_with("sotano.tscn"):
			texto_interaccion.text = "[Z] Subir al segundo piso"
		else:
			texto_interaccion.text = "[Z] Bajar al sótano"

		texto_interaccion.visible = true
	else:
		texto_interaccion.visible = false
