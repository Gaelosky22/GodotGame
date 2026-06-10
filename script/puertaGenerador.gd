extends Node3D

var abierta = false

func _ready():
	add_to_group("puertas_generador")
	if GameState.puerta_generador_abierta:
		abierta = true
		rotation.y += deg_to_rad(90)

func interactuar():
	print("Estado GameState al intentar abrir: ", GameState.generadores_encendidos)
	print("Cables: ", GameState.cables_reparados)
	if abierta: return
	var generadores_listos = GameState.generadores_encendidos.size()
	
	if generadores_listos >= 2 and GameState.cables_reparados:
		_abrir()
	else:
		var jugadores = get_tree().get_nodes_in_group("jugador")
		if jugadores.is_empty(): return
		var jugador = jugadores[0]
		
		if not GameState.cables_reparados and generadores_listos < 2:
			jugador.mostrar_mensaje_temporal("Necesitas encender %d generador(es) más y reparar los cables" % (2 - generadores_listos))
		elif not GameState.cables_reparados:
			jugador.mostrar_mensaje_temporal("Necesitas reparar los cables del primer piso")
		elif generadores_listos < 2:
			jugador.mostrar_mensaje_temporal("Necesitas encender %d generador(es) más" % (2 - generadores_listos))

func _abrir():
	abierta = true
	GameState.marcar_puerta_generador()
	MisionHUD.actualizar()
	# Fade a negro y cambiar escena
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null: return
	jugador.bloqueado = true
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var capa = CanvasLayer.new()
	capa.layer = 99
	jugador.add_child(capa)
	capa.add_child(fade)
	var tween = create_tween()
	tween.tween_property(fade, "color", Color(0, 0, 0, 1), 0.8)
	await tween.finished
	get_tree().change_scene_to_file("res://creditos/creditos.tscn")
