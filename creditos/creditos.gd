extends Node

# ============================================================
#  creditos.gd  —  La Casa del Terror
#  Flujo: créditos animados (66s) → pausa 5s → créditos clásicos (60s) → quit
# ============================================================

# --- nodos (se crean por código, no necesitas nada en la escena salvo un Node raíz) ---
var audio_player : AudioStreamPlayer
var capa_animados : CanvasLayer
var capa_clasicos : CanvasLayer
var fase_creditos: String = "intro"  # "intro", "animados", "clasicos"

# --- imágenes disponibles en res://creditos/animado/ ---
const IMAGENES := [
	"res://creditos/animado/Inicio.png",
	"res://creditos/animado/Spawn Jugador.png",
	"res://creditos/animado/Pasillo1.png",
	"res://creditos/animado/Generador.png",
	"res://creditos/animado/Vela adorno.png",
	"res://creditos/animado/puertallave.png",
	"res://creditos/animado/Llave.png",
	"res://creditos/animado/Puerta Generador.png",
	"res://creditos/animado/Escondite.png",
	"res://creditos/animado/Escondite cama.png",
	"res://creditos/animado/Monstruo piso1.png",
	"res://creditos/animado/Pasillo Monstruo.png",
	"res://creditos/animado/Pasillo viejita.png",
	"res://creditos/animado/MiniJuego.png",
	"res://creditos/animado/JugandoMinijuego.png",
	"res://creditos/animado/Cuarto Cerrado.png",
	"res://creditos/animado/Entrada Piso2.png",
	"res://creditos/animado/Puerta piso2.png",
	"res://creditos/animado/piso2.png",
	"res://creditos/animado/Pasillo piso2.png",
	"res://creditos/animado/Area Monstruo2.png",
	"res://creditos/animado/MonstruoPiso2.png",
	"res://creditos/animado/Monstruo Piso2 acechando.png",
	"res://creditos/animado/Monstruopiso2 corriendo.png",
]

# --- datos de los créditos animados (texto que aparece sobre cada foto) ---
# Cada entrada: [imagen_index, titulo, descripcion]
const SLIDES := [
	# ——— INTRO ———
	[0,  "LA CASA DEL TERROR", ""],
	# ——— PISO 1 ———
	[2,  "El Inicio", "Todo comenzó aquí..."],
	[3,  "Los Generadores", "Dos máquinas. Dos esperanzas."],
	[6,  "La Llave", "Una llave. Una salida."],
	[7,  "La Puerta Final", "El escape... si sobrevives."],
	[8,  "El Armario", "Quieto. No respires."],
	[9,  "Bajo la Cama", "Quizás no te vea."],
	[10, "El Monstruo", "Siempre al acecho."],
	[12, "La Viejita", "No todo es lo que parece."],
	[13, "El Minijuego", "Repara los cables o muere."],
	# ——— PISO 2 ———
	[16, "Segundo Piso", "Pensabas que era el final..."],
	[19, "Los Pasillos", "Cada esquina, un peligro."],
	[21, "La Nueva Amenaza", "Más rápido. Más inteligente."],
	[22, "Al Acecho", "Te está buscando."],
	[23, "La Persecución", "¡CORRE!"],
	# ——— CRÉDITOS ———
	[0,  "DIRECCIÓN & PROGRAMACIÓN", "Fredy Noel Castro Jauna\n\"Rider\""],
	[0,  "DISEÑO & MECÁNICAS", "Luis Gael Gutierrez Sainz\n\"El Compadre\""],
	[0,  "TESTERS", "Juan · Brandon\nLeobardo Gabriel · Sebastian"],
	[0,  "UN JUEGO DE", "Rider & El Compadre"],
	[0,  "LA CASA DEL TERROR", "© 2026"],
]

# ============================================================
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	set_process_input(true)
	fase_creditos = "intro"
	_reproducir_intro()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_saltar_creditos()
	elif event is InputEventMouseButton and event.pressed:
		_saltar_creditos()


func _saltar_creditos() -> void:
	match fase_creditos:
		"intro":
			# Saltar cinemática inicial
			for child in get_children():
				if child is CanvasLayer and child != capa_animados:
					child.queue_free()
			fase_creditos = "animados"
			_iniciar_animados()
		
		"animados":
			# Saltar créditos animados
			if capa_animados:
				capa_animados.queue_free()
				capa_animados = null
			if audio_player and audio_player.playing:
				audio_player.stop()
			fase_creditos = "clasicos"
			_iniciar_clasicos()
		
		"clasicos":
			# Saltar créditos clásicos y salir del juego
			if capa_clasicos:
				capa_clasicos.queue_free()
			get_tree().quit()

func _reproducir_intro() -> void:
	var capa_intro := CanvasLayer.new()
	capa_intro.layer = 10
	add_child(capa_intro)

	# Fondo negro
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa_intro.add_child(bg)

	# Video
	var video := VideoStreamPlayer.new()
	video.stream = load("res://AnimacionFinal/logo_juego.ogv")
	video.expand = true
	video.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa_intro.add_child(video)

	# Audio sincronizado
	var audio := AudioStreamPlayer.new()
	audio.stream = load("res://AnimacionFinal/Video-logo.mp3")
	capa_intro.add_child(audio)

	video.play()
	audio.play()

	# Esperar a que termine el video o el audio (el que dure más)
	await video.finished
	if audio.playing:
		await audio.finished

	capa_intro.queue_free()
	fase_creditos = "animados"
	_iniciar_animados()
	
# ============================================================
#   CRÉDITOS ANIMADOS
# ============================================================
func _iniciar_animados() -> void:
	fase_creditos = "animados"
	capa_animados = CanvasLayer.new()
	capa_animados.layer = 10
	add_child(capa_animados)

	# Fondo negro permanente
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa_animados.add_child(bg)

	# Audio
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	var stream = load("res://creditos/animado/La La La.mp3")
	if stream:
		audio_player.stream = stream
		audio_player.play()

	# Lanzar la secuencia de slides
	_reproducir_slides()

func _reproducir_slides() -> void:
	var duracion_total := 66.0          # 1 minuto 6 segundos
	var n_slides := SLIDES.size()
	var tiempo_por_slide := duracion_total / n_slides   # ~3.3 s por slide

	for i in n_slides:
		var datos = SLIDES[i]
		var img_index : int = datos[0]
		var titulo : String = datos[1]
		var descripcion : String = datos[2]

		await _mostrar_slide(img_index, titulo, descripcion, tiempo_por_slide)

	# Terminaron los animados → fade a negro y pausa 5s
	await _fade_negro(capa_animados, 1.0)
	capa_animados.queue_free()
	audio_player.stop()
	await get_tree().create_timer(5.0).timeout
	_iniciar_clasicos()

func _mostrar_slide(img_idx: int, titulo: String, desc: String, duracion: float) -> void:
	# Contenedor del slide
	var slide_root := Control.new()
	slide_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	slide_root.modulate.a = 0.0
	capa_animados.add_child(slide_root)

	# Imagen de fondo (si aplica)
		# Imagen de fondo (si aplica)
	if img_idx < IMAGENES.size():
		var tex = load(IMAGENES[img_idx]) as Texture2D
		if tex:
			var img_rect := TextureRect.new()
			img_rect.texture = tex
			img_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			img_rect.modulate = Color(1, 1, 1, 0.85)   # ✅ Más visible, solo un poco oscurecida
			slide_root.add_child(img_rect)

	# Overlay semitransparente solo en los bordes (viñeta)
	var overlay := ColorRect.new()
	# Degradado radial no es fácil con ColorRect; mejor usa un panel más claro
	overlay.color = Color(0, 0, 0, 0.3)   # ✅ Menos opaco (0.3 en vez de 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	slide_root.add_child(overlay)

	# Contenedor vertical centrado
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical   = Control.GROW_DIRECTION_BOTH
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 18)
	slide_root.add_child(vbox)

	# Línea decorativa superior
	if titulo != "":
		var linea_sup := Label.new()
		linea_sup.text = "────────────────"
		linea_sup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		linea_sup.add_theme_color_override("font_color", Color(0.6, 0.0, 0.0, 1))
		vbox.add_child(linea_sup)

	# Título
	var lbl_titulo := Label.new()
	lbl_titulo.text = titulo
	lbl_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_titulo.add_theme_font_size_override("font_size", 52)
	lbl_titulo.add_theme_color_override("font_color", Color(0.95, 0.85, 0.6, 1))  # dorado
	lbl_titulo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	lbl_titulo.add_theme_constant_override("shadow_offset_x", 3)
	lbl_titulo.add_theme_constant_override("shadow_offset_y", 3)
	vbox.add_child(lbl_titulo)

	# Descripción
	if desc != "":
		var lbl_desc := Label.new()
		lbl_desc.text = desc
		lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_desc.add_theme_font_size_override("font_size", 30)
		lbl_desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
		lbl_desc.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
		lbl_desc.add_theme_constant_override("shadow_offset_x", 2)
		lbl_desc.add_theme_constant_override("shadow_offset_y", 2)
		vbox.add_child(lbl_desc)

	# Línea decorativa inferior
	if titulo != "":
		var linea_inf := Label.new()
		linea_inf.text = "────────────────"
		linea_inf.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		linea_inf.add_theme_color_override("font_color", Color(0.6, 0.0, 0.0, 1))
		vbox.add_child(linea_inf)

	# Centrar el vbox manualmente (no tiene tamaño fijo)
	await get_tree().process_frame
	vbox.position = Vector2(
		(get_viewport().size.x - vbox.size.x) / 2.0,
		(get_viewport().size.y - vbox.size.y) / 2.0
	)

	# Fade IN
	var t_in := create_tween()
	t_in.tween_property(slide_root, "modulate:a", 1.0, 0.6)
	await t_in.finished

	# Esperar en pantalla
	var tiempo_visible := duracion - 1.4   # 0.6 fade in + 0.8 fade out
	await get_tree().create_timer(max(tiempo_visible, 0.3)).timeout

	# Fade OUT
	var t_out := create_tween()
	t_out.tween_property(slide_root, "modulate:a", 0.0, 0.8)
	await t_out.finished

	slide_root.queue_free()

# ============================================================
#   CRÉDITOS CLÁSICOS (texto subiendo)
# ============================================================
const CREDITOS_TEXTO := """
LA CASA DEL TERROR




─────────────────────


DIRECCIÓN GENERAL

Fredy Noel Castro Jauna
"Rider"

Luis Gael Gutierrez Sainz
"El Compadre"


─────────────────────


PROGRAMACIÓN

Fredy Noel Castro Jauna — Rider
Mecánicas de llave y puerta
Galones y generadores
Puerta de escape final
IA del monstruo del primer piso
Animaciones y jumpscares
Audios y efectos de sonido
Segunda idea del segundo piso

Luis Gael Gutierrez Sainz — El Compadre
Funcionamiento del segundo piso
Diseño y estructura del mapa


─────────────────────


DISEÑO DE NIVELES

Fredy Noel Castro Jauna
Primer boceto del mapa

Luis Gael Gutierrez Sainz
Diseño y decoración del mapa
Modelo y área del segundo piso


─────────────────────


ARTE & ANIMACIONES

Fredy Noel Castro Jauna "Rider"
Todas las animaciones del juego
Jumpscares
La viejita


─────────────────────


MECÁNICAS DE JUEGO

Escondite en armarios — El Compadre
Escondite en camas — El Compadre
Minijuego de cables — El Compadre
Sistema de galones — Rider
Generadores — Rider


─────────────────────


ENEMIGOS

Monstruo Piso 1
Modelo: El Compadre
IA & Rutas: Rider

La Viejita
Rider

Monstruo Piso 2
El Compadre


─────────────────────


AUDIO

Música y efectos de sonido
Fredy Noel Castro Jauna "Rider"


─────────────────────


JUEGO 2D

Luis Gael Gutierrez Sainz
"El Compadre"
(Diseño y programación completos)


─────────────────────


AGRADECIMIENTOS ESPECIALES

Juan
Brandon
Leobardo Gabriel
Sebastian
Daniel

Gracias por testear el juego
y aguantar los sustos.


─────────────────────


HECHO CON

Godot Engine 4
y Ursina


─────────────────────


Un proyecto de

Rider  &  El Compadre


─────────────────────




LA CASA DEL TERROR

© 2026  Todos los derechos reservados



"""

func _iniciar_clasicos() -> void:
	fase_creditos = "clasicos"
	capa_clasicos = CanvasLayer.new()
	capa_clasicos.layer = 10
	add_child(capa_clasicos)

	# Fondo negro
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	capa_clasicos.add_child(bg)

	# SubViewport size
	var vp_size: Vector2 = get_viewport().size

	# Label con todo el texto
	var lbl := Label.new()
	lbl.text = CREDITOS_TEXTO
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	lbl.add_theme_font_size_override("font_size", 26)
	lbl.add_theme_color_override("font_color", Color(0.92, 0.88, 0.75, 1))
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	lbl.add_theme_constant_override("shadow_offset_x", 2)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.custom_minimum_size = Vector2(vp_size.x * 0.6, 0)
	lbl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	capa_clasicos.add_child(lbl)

	# Esperar un frame para que se calcule el tamaño del label
	await get_tree().process_frame
	await get_tree().process_frame

	var texto_h := lbl.size.y
	# Empieza abajo de la pantalla y sube hasta que el último renglón salga por arriba
	var y_inicio := vp_size.y
	var y_final  := -texto_h - 100.0
	var distancia := y_inicio - y_final

	# Centrar horizontalmente
	lbl.position.x = (vp_size.x - lbl.size.x) / 2.0
	lbl.position.y = y_inicio

	# Fade in del fondo
	# Fade in del fondo
	bg.modulate.a = 0.0
	var t_fade := create_tween()
	t_fade.tween_property(bg, "modulate:a", 1.0, 1.5)
	await t_fade.finished

	# Tween de scroll — 60 segundos exactos
	var duracion_scroll := 60.0
	var tween_scroll := create_tween()
	tween_scroll.tween_property(lbl, "position:y", y_final, duracion_scroll).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	await tween_scroll.finished

	# Fade a negro y cerrar el juego
	var t_out := create_tween()
	t_out.tween_property(bg, "modulate:a", 0.0, 2.0)
	await t_out.finished

	get_tree().quit()

# ============================================================
#   HELPER: fade a negro de una capa
# ============================================================
func _fade_negro(capa: CanvasLayer, duracion: float) -> void:
	var rect := ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	capa.add_child(rect)
	var tw := create_tween()
	tw.tween_property(rect, "color:a", 1.0, duracion)
	await tw.finished
