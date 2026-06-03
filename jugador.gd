extends CharacterBody3D

var golpes = 0
var golpes_maximos = 3
var muerto = false

var velocidad = 5.0
var velocidad_con_carga = 2.8   # más lento cargando galón
var gravedad = 9.8
var sensibilidad_mouse = 0.002

var cama_posicion = Vector3.ZERO

# Esconderse
var escondido = false
var puede_esconderse = false
var posicion_normal = Vector3(0, 0.7, 0)
var posicion_escondido = Vector3(0, -0.3, 0)
var bloqueado = false

# Linterna
var linterna_encendida = true
var overlay_dano: ColorRect

# Puertas / interacción
var puerta_cercana = null
var objeto_cercano = null       # objeto que se puede agarrar
var objeto_en_mano = null       # objeto que se está cargando
var texto_interaccion: Label
var label_objeto_en_mano: Label

# Stamina
var stamina = 100.0
var stamina_maxima = 100.0
var gasto_stamina = 25.0
var recuperacion_stamina = 75.0
var puede_correr = true
var timer_recuperacion = 0.0
var delay_recuperacion = 3.0
var recuperando = false

# Temblor cámara
var tiempo_temblor = 0.0

# HUD
var hud : CanvasLayer

var cinematica_muerte = null

@onready var camara = $Camera3D
@onready var linterna = $Camera3D/SpotLight3D

func _ready():
	add_to_group("jugador")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crear_hud()
	# Audio de inicio
	await get_tree().create_timer(15.0).timeout
	if not is_inside_tree(): return
	var audio_inicio = AudioStreamPlayer.new()
	audio_inicio.stream = load("res://sonidos/empiezas a moverte.mp3")
	get_tree().current_scene.add_child(audio_inicio)
	audio_inicio.play()
	await audio_inicio.finished
	audio_inicio.queue_free()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	cinematica_muerte = load("res://cinematic/animation_muerte.ogv")

# ─── HUD ───────────────────────────────────────────────────────────────────

func crear_hud():
	hud = CanvasLayer.new()
	add_child(hud)

	# Fondo stamina
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

	# Label objeto en mano (abajo centro)
	label_objeto_en_mano = Label.new()
	label_objeto_en_mano.name = "LabelObjeto"
	label_objeto_en_mano.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_objeto_en_mano.add_theme_font_size_override("font_size", 20)
	label_objeto_en_mano.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	label_objeto_en_mano.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	label_objeto_en_mano.position.y = -60
	label_objeto_en_mano.visible = false
	hud.add_child(label_objeto_en_mano)

	# Texto interacción (centro pantalla)
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

	# Overlay daño
	overlay_dano = ColorRect.new()
	overlay_dano.color = Color(1, 0, 0, 0.0)
	overlay_dano.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay_dano.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(overlay_dano)

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

	# Texto interacción
	var hint = ""
	if objeto_cercano != null and objeto_en_mano == null:
		hint = "[E] Recoger " + objeto_cercano.nombre_display
	elif objeto_en_mano != null:
		hint = "[E] Soltar " + objeto_en_mano.nombre_display
	elif puerta_cercana != null:
		hint = "[E] Abrir puerta"

	texto_interaccion.text = hint
	texto_interaccion.visible = hint != ""

	# Label objeto en mano
	if objeto_en_mano != null:
		label_objeto_en_mano.text = "Cargando: " + objeto_en_mano.nombre_display
		label_objeto_en_mano.visible = true
	else:
		label_objeto_en_mano.visible = false

# ─── INPUT ─────────────────────────────────────────────────────────────────

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensibilidad_mouse)
		camara.rotate_x(-event.relative.y * sensibilidad_mouse)
		camara.rotation.x = clamp(camara.rotation.x, -1.2, 1.2)

	if event is InputEventKey and event.pressed and not event.echo:

		if event.keycode == KEY_ESCAPE:
			mostrar_menu_pausa()

		elif event.keycode == KEY_F:
			linterna_encendida = !linterna_encendida
			linterna.visible = linterna_encendida

		elif event.keycode == KEY_E:
			_interactuar()

# ─── INTERACCIÓN ───────────────────────────────────────────────────────────

func _interactuar():
	# Si cargo algo, intentar usarlo en generador/puerta cercana
	if objeto_en_mano != null:
		# Ver si hay generador o puerta cerca para depositar
		var depositado = await _intentar_depositar()
		if depositado:
			return
		# Si no, soltar en el suelo
		_soltar_objeto()
		return

	# Agarrar objeto cercano
	if objeto_cercano != null:
		_agarrar_objeto(objeto_cercano)
		return

	# Interactuar con puerta
	if puerta_cercana != null:
		if puerta_cercana.has_method("interactuar"):
			puerta_cercana.interactuar()
		return

	# Esconderse
	if puede_esconderse:
		escondido = !escondido
		if escondido:
			camara.position = Vector3(0, 2.5, 3.0)
			camara.rotation.x = deg_to_rad(-25)
			bloqueado = true
		else:
			camara.position = posicion_normal
			camara.rotation.x = 0.0
			bloqueado = false

func _agarrar_objeto(obj):
	objeto_en_mano = obj
	obj.agarrar(camara)   # el objeto se adjunta a la cámara

func _soltar_objeto():
	if objeto_en_mano == null: return
	objeto_en_mano.soltar()
	objeto_en_mano = null

func _intentar_depositar() -> bool:
	# Buscar generador o puerta cercana que acepte el objeto
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
	texto_interaccion.text = texto
	texto_interaccion.visible = true
	await get_tree().create_timer(duracion).timeout
	if is_inside_tree():
		texto_interaccion.visible = false

# ─── FÍSICA ────────────────────────────────────────────────────────────────

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravedad * delta

	if bloqueado:
		velocity.x = 0
		velocity.z = 0
		move_and_slide()
		return

	var corriendo = Input.is_key_pressed(KEY_SHIFT) and puede_correr and stamina > 0

	# Velocidad base — más lento si carga galón
	var vel_base = velocidad_con_carga if (objeto_en_mano != null and objeto_en_mano.es_pesado) else velocidad
	var vel = vel_base * 1.6 if corriendo else vel_base

	# Stamina
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

	# Movimiento
	var direccion = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): direccion -= transform.basis.z
	if Input.is_key_pressed(KEY_S): direccion += transform.basis.z
	if Input.is_key_pressed(KEY_A): direccion -= transform.basis.x
	if Input.is_key_pressed(KEY_D): direccion += transform.basis.x
	if direccion != Vector3.ZERO:
		direccion = direccion.normalized()

	# Temblor cámara al correr
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

func morir():
	if muerto: return
	muerto = true
	bloqueado = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_reproducir_cinematica_muerte()

func _reproducir_cinematica_muerte():
	var capa = CanvasLayer.new()
	capa.layer = 10
	add_child(capa)
	
	# Pantalla negra inmediata
	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 1)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_child(fondo)
	
	# Silenciar todo
	AudioServer.set_bus_volume_db(0, -80)
	
	if cinematica_muerte == null:
		print("ERROR: cinematica no cargada")
		mostrar_menu_muerte()
		return
	
	var video = VideoStreamPlayer.new()
	video.stream = cinematica_muerte
	video.expand = true
	video.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa.add_child(video)
	video.play()
	print("Video playing: ", video.is_playing())
	
	# Timeout de seguridad — si el video no termina en 30s igual muestra el menú
	var timer = get_tree().create_timer(30.0)
	await video.finished
	mostrar_menu_muerte()
	AudioServer.set_bus_volume_db(0, 0)

func mostrar_menu_muerte():
	var menu = CanvasLayer.new()
	menu.name = "MenuMuerte"
	add_child(menu)

	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.85)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.add_child(fondo)

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
	menu.add_child(btn_reiniciar)
	btn_reiniciar.pressed.connect(func(): get_tree().reload_current_scene())

	var btn_salir = Button.new()
	btn_salir.text = "SALIR"
	btn_salir.size = Vector2(300, 60)
	btn_salir.position = Vector2(get_viewport().size.x / 2 - 150, 410)
	menu.add_child(btn_salir)
	btn_salir.pressed.connect(func(): get_tree().quit())

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
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED))
		elif dato[0] == "REINICIAR":
			btn.pressed.connect(func():
				get_tree().paused = false
				get_tree().reload_current_scene())
		else:
			btn.pressed.connect(func(): get_tree().quit())
