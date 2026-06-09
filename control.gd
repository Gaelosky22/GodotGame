extends Control

func _ready():
	# El Control ocupa toda la ventana
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size

	# Fondo negro
	var fondo = ColorRect.new()
	fondo.color = Color.BLACK
	fondo.anchor_left = 0.0
	fondo.anchor_top = 0.0
	fondo.anchor_right = 1.0
	fondo.anchor_bottom = 1.0
	add_child(fondo)

	await get_tree().process_frame

	# Hoja
	var panel = ColorRect.new()
	panel.color = Color(0.96, 0.94, 0.88)
	panel.size = Vector2(420, 460)
	panel.position = (Vector2(get_viewport().size) - panel.size) / 2.0
	add_child(panel)

	# Texto
	var texto = RichTextLabel.new()
	texto.bbcode_enabled = true
	texto.size = Vector2(380, 420)
	texto.position = Vector2(20, 20)
	texto.scroll_active = false

	texto.add_theme_font_size_override("normal_font_size", 14)
	texto.add_theme_color_override("default_color", Color(0.1, 0.05, 0.0))

	texto.text = """[center][i]— Nota encontrada —[/i][/center]

Despertaste encerrado en el sótano de Don Aurelio.

La puerta principal tiene un mecanismo eléctrico — necesitas activar los [b]dos generadores[/b] con gasolina. Los galones están escondidos por el sótano. Búscalos y deposítalos en los generadores cerca de la salida.

[color=#660000][i]Cuidado — no estás solo aquí abajo.[/i][/color]

Hay algo que patrulla. Te golpea [b]tres veces[/b] y es el fin. Escóndete si te ve.

En el piso de arriba es distinto — aparece sin avisar. [b]Apaga la linterna. No te muevas. Espera.[/b] Es tu única oportunidad.

[right][i]Buena suerte.[/i][/right]"""

	panel.add_child(texto)

	# Mensaje inferior
	var hint = Label.new()
	hint.text = "Presiona cualquier tecla para continuar"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size = Vector2(get_viewport().size.x, 30)
	hint.position = Vector2(0, get_viewport().size.y - 50)

	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

	add_child(hint)

	# Parpadeo
	var tween = create_tween().set_loops()
	tween.tween_property(hint, "modulate:a", 0.2, 1.0)
	tween.tween_property(hint, "modulate:a", 1.0, 1.0)

func _input(event):
	if event is InputEventKey and event.pressed:
		get_tree().change_scene_to_file("res://sotano.tscn")

	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://sotano.tscn")
