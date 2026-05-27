extends CharacterBody3D

var golpes = 0
var golpes_maximos = 3
var muerto = false

var velocidad = 5.0
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
# Puertas
var puerta_cercana = null
var texto_interaccion: Label

# Stamina estilo Halo Reach
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

@onready var camara = $Camera3D
@onready var linterna = $Camera3D/SpotLight3D


func _ready():
	add_to_group("jugador")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crear_hud()

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

	titulo.text = "CONFIGURACIÓN"

	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	titulo.add_theme_font_size_override(
		"font_size",
		56
	)

	titulo.add_theme_color_override(
		"font_color",
		Color.WHITE
	)

	titulo.set_anchors_preset(Control.PRESET_TOP_WIDE)

	titulo.position.y = 110

	menu.add_child(titulo)

	# VOLVER
	var btn_reanudar = Button.new()

	btn_reanudar.text = "VOLVER"

	btn_reanudar.size = Vector2(300, 60)

	btn_reanudar.position = Vector2(
		get_viewport().size.x / 2 - 150,
		300
	)

	menu.add_child(btn_reanudar)

	btn_reanudar.pressed.connect(func():

		menu.queue_free()

		get_tree().paused = false

		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED
		)
	)

	# REINICIAR
	var btn_reiniciar = Button.new()

	btn_reiniciar.text = "REINICIAR"

	btn_reiniciar.size = Vector2(300, 60)

	btn_reiniciar.position = Vector2(
		get_viewport().size.x / 2 - 150,
		380
	)

	menu.add_child(btn_reiniciar)

	btn_reiniciar.pressed.connect(func():

		get_tree().paused = false

		get_tree().reload_current_scene()
	)

	# SALIR
	var btn_salir = Button.new()

	btn_salir.text = "SALIR"

	btn_salir.size = Vector2(300, 60)

	btn_salir.position = Vector2(
		get_viewport().size.x / 2 - 150,
		460
	)

	menu.add_child(btn_salir)

	btn_salir.pressed.connect(func():

		get_tree().quit()
	)
func crear_hud():

	hud = CanvasLayer.new()
	add_child(hud)

	# Fondo stamina
	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.6)
	fondo.size = Vector2(204, 18)
	fondo.position = Vector2(20, 20)
	hud.add_child(fondo)

	# Barra stamina
	var barra = ColorRect.new()
	barra.name = "BarraStamina"
	barra.color = Color(0.2, 0.8, 0.3)
	barra.size = Vector2(200, 14)
	barra.position = Vector2(22, 22)
	hud.add_child(barra)

	# Overlay daño rojo
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

	# Mostrar aviso tipo Granny
	if texto_interaccion != null:
		texto_interaccion.visible = puerta_cercana != null


func _input(event):

	# Movimiento de cámara
	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * sensibilidad_mouse)

		camara.rotate_x(-event.relative.y * sensibilidad_mouse)

		camara.rotation.x = clamp(
			camara.rotation.x,
			-1.2,
			1.2
		)

	# Teclas
	if event is InputEventKey and event.pressed and not event.echo:

		# Pausa
		if event.keycode == KEY_ESCAPE:
			mostrar_menu_pausa()

		# Linterna
		elif event.keycode == KEY_F:

			linterna_encendida = !linterna_encendida
			linterna.visible = linterna_encendida

		# Interactuar
		elif event.keycode == KEY_E:
			print("Presionaste E")

			if puerta_cercana != null:
				print("Intentando abrir puerta:", puerta_cercana.name)
				puerta_cercana.interactuar()
				return
			else:
				print("No hay puerta cercana")

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


func _physics_process(delta):

	# Gravedad
	if not is_on_floor():
		velocity.y -= gravedad * delta

	# Bloqueado
	if bloqueado:

		velocity.x = 0
		velocity.z = 0

		move_and_slide()
		return

	# Sprint
	var corriendo = (
		Input.is_key_pressed(KEY_SHIFT)
		and puede_correr
		and stamina > 0
	)

	var vel = velocidad * 1.6 if corriendo else velocidad

	# Sistema stamina
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

	if Input.is_key_pressed(KEY_W):
		direccion -= transform.basis.z

	if Input.is_key_pressed(KEY_S):
		direccion += transform.basis.z

	if Input.is_key_pressed(KEY_A):
		direccion -= transform.basis.x

	if Input.is_key_pressed(KEY_D):
		direccion += transform.basis.x

	if direccion != Vector3.ZERO:
		direccion = direccion.normalized()

	# Temblor cámara
	if corriendo and direccion != Vector3.ZERO:

		tiempo_temblor += delta * 12.0

		camara.rotation.z = sin(tiempo_temblor) * 0.04
		camara.rotation.x += sin(tiempo_temblor * 1.3) * 0.006

	else:

		tiempo_temblor = 0.0

		camara.rotation.z = lerp(
			camara.rotation.z,
			0.0,
			delta * 10.0
		)

	# Movimiento final
	velocity.x = direccion.x * vel
	velocity.z = direccion.z * vel
	
	move_and_slide()

func recibir_golpe():
	if muerto:
		return

	golpes += 1
	print("Jugador recibió golpe:", golpes)

	if overlay_dano != null:
		overlay_dano.color = Color(1, 0, 0, 0.45)

		var tween = create_tween()
		tween.tween_property(
			overlay_dano,
			"color",
			Color(1, 0, 0, 0.0),
			0.35
		)

	if golpes >= golpes_maximos:
		morir()
		
func morir():
	if muerto:
		return

	muerto = true
	bloqueado = true

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	mostrar_menu_muerte()
	
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

	btn_reiniciar.pressed.connect(func():
		get_tree().reload_current_scene()
	)

	var btn_salir = Button.new()
	btn_salir.text = "SALIR"
	btn_salir.size = Vector2(300, 60)
	btn_salir.position = Vector2(get_viewport().size.x / 2 - 150, 410)
	menu.add_child(btn_salir)

	btn_salir.pressed.connect(func():
		get_tree().quit()
	)
