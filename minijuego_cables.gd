extends Control

signal completado
signal cancelado

const COLORES = [Color.RED, Color.YELLOW, Color.CYAN, Color.GREEN, Color.MAGENTA, Color.ORANGE]
const NUM_CABLES = 6

var puntos_izq = []
var puntos_der = []
var conexiones = {}
var arrastrando = -1
var mouse_pos = Vector2.ZERO
var orden_der = []

func _ready():
	# Que cubra toda la pantalla
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	orden_der = range(NUM_CABLES)
	orden_der.shuffle()

func _calcular_puntos():
	var panel = $Panel
	var rect = panel.get_global_rect()
	puntos_izq.clear()
	puntos_der.clear()
	
	var margen_x = 80.0
	var margen_y = 80.0
	var alto_util = rect.size.y - margen_y * 2

	for i in NUM_CABLES:
		var y = rect.position.y + margen_y + (alto_util / (NUM_CABLES - 1)) * i
		puntos_izq.append(Vector2(rect.position.x + margen_x, y))
		puntos_der.append(Vector2(rect.position.x + rect.size.x - margen_x, y))

func _draw():
	_calcular_puntos()
	
	# Líneas ya conectadas
	for i in conexiones:
		draw_line(puntos_izq[i], puntos_der[conexiones[i]], COLORES[i], 5.0, true)
	
	# Línea que se arrastra
	if arrastrando >= 0:
		draw_line(puntos_izq[arrastrando], mouse_pos, COLORES[arrastrando], 5.0, true)
	
	# Puntos izquierda
	for i in NUM_CABLES:
		draw_circle(puntos_izq[i], 13, COLORES[i])
	
	# Puntos derecha (mezclados)
	for i in NUM_CABLES:
		draw_circle(puntos_der[i], 13, COLORES[orden_der[i]])

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		cancelado.emit()

	if event is InputEventMouseMotion:
		mouse_pos = get_global_mouse_position()
		queue_redraw()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			for i in puntos_izq.size():
				if puntos_izq[i].distance_to(get_global_mouse_position()) < 16:
					arrastrando = i
					conexiones.erase(i)
					break
		else:
			if arrastrando >= 0:
				for i in puntos_der.size():
					if puntos_der[i].distance_to(get_global_mouse_position()) < 16:
						conexiones[arrastrando] = i
						break
				arrastrando = -1
				queue_redraw()
				_verificar()

func _verificar():
	if conexiones.size() < NUM_CABLES:
		return
	for i in NUM_CABLES:
		if not conexiones.has(i):
			return
		if orden_der[conexiones[i]] != i:
			return
	completado.emit()
