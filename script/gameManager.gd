# Crea un Node3D en la raíz de tu escena, llámalo "GameManager" y pégale este script
extends Node3D

var generadores_encendidos = 0
var llave_recogida = false

@onready var mega_puerta = get_tree().get_root().find_child("puertagenerador", true, false)

func generador_encendido(id: int):
	generadores_encendidos += 1
	print("Generadores encendidos: ", generadores_encendidos)
	if generadores_encendidos >= 2:
		_abrir_mega_puerta()

func _abrir_mega_puerta():
	print("¡MEGA PUERTA ABIERTA! Capítulo 1 completado")
	if mega_puerta and mega_puerta.has_method("abrir_automatico"):
		mega_puerta.abrir_automatico()

	# Mostrar mensaje de victoria
	await get_tree().create_timer(1.5).timeout
	_mostrar_victoria()

func _mostrar_victoria():
	var jugador = get_tree().get_nodes_in_group("jugador")
	if jugador.is_empty(): return
	jugador[0].bloqueado = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var menu = CanvasLayer.new()
	get_tree().current_scene.add_child(menu)

	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.9)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu.add_child(fondo)

	var titulo = Label.new()
	titulo.text = "CAPÍTULO 1 COMPLETADO"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 48)
	titulo.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	titulo.set_anchors_preset(Control.PRESET_TOP_WIDE)
	titulo.position.y = 120
	menu.add_child(titulo)

	var historia = Label.new()
	historia.text = "Lograste escapar del sótano de Don Aurelio.\nEl bosque te espera..."
	historia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	historia.add_theme_font_size_override("font_size", 22)
	historia.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	historia.set_anchors_preset(Control.PRESET_TOP_WIDE)
	historia.position.y = 240
	menu.add_child(historia)

	var btn = Button.new()
	btn.text = "SALIR AL MENÚ"
	btn.size = Vector2(300, 60)
	btn.position = Vector2(get_viewport().size.x / 2 - 150, 400)
	menu.add_child(btn)
	btn.pressed.connect(func(): get_tree().quit())
