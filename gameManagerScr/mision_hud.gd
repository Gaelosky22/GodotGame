# mision_hud.gd
extends CanvasLayer

var visible_panel = false
var panel: PanelContainer
var lista: VBoxContainer

func _ready():
	layer = 10
	_construir_panel()

func _construir_panel():
	panel = PanelContainer.new()
	panel.position = Vector2(20, 20)
	panel.custom_minimum_size = Vector2(220, 0)
	panel.visible = false
	add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var titulo = Label.new()
	titulo.text = "Misiones"
	titulo.add_theme_font_size_override("font_size", 16)
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.2))
	vbox.add_child(titulo)

	vbox.add_child(HSeparator.new())

	lista = VBoxContainer.new()
	lista.add_theme_constant_override("separation", 4)
	vbox.add_child(lista)

	_actualizar_lista()

func _actualizar_lista():
	for hijo in lista.get_children():
		hijo.queue_free()

	_agregar_seccion("Sótano:")
	_agregar_mision("Llenar generador 1", GameState.generador_fue_encendido("generador1"))
	_agregar_mision("Llenar generador 2", GameState.generador_fue_encendido("generador2"))

	_agregar_seccion("Piso 1:")
	_agregar_mision("Arregla el cableado", GameState.cables_reparados)

func _agregar_seccion(texto: String):
	var label = Label.new()
	label.text = texto
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 0.8))
	lista.add_child(label)

func _agregar_mision(texto: String, completada: bool):
	var rich = RichTextLabel.new()
	rich.bbcode_enabled = true
	rich.fit_content = true
	rich.scroll_active = false
	rich.custom_minimum_size.x = 200
	if completada:
		rich.text = "  [s]" + texto + "[/s]"
		rich.add_theme_color_override("default_color", Color(0.5, 0.5, 0.5))
	else:
		rich.text = "  " + texto
		rich.add_theme_color_override("default_color", Color(1, 1, 1, 0.9))
	lista.add_child(rich)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		visible_panel = !visible_panel
		panel.visible = visible_panel
		if visible_panel:
			_actualizar_lista()

func actualizar():
	if visible_panel:
		_actualizar_lista()
