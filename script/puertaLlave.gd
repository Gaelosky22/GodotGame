# Pega este script al nodo "puertaLlave"
extends Node3D

var abierta = false

func _ready():
	add_to_group("puertas_llave")

# Llamado cuando el jugador presiona E cerca
func interactuar():
	if abierta: return

	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.is_empty(): return
	var jugador = jugadores[0]

	if jugador.objeto_en_mano != null:
		if jugador.objeto_en_mano.nombre_display.to_lower().contains("llave"):
			_abrir(jugador)
			return

	print("Necesitas la llave para abrir esta puerta")

func recibir_objeto(objeto) -> bool:
	if abierta: return false
	if objeto.nombre_display.to_lower().contains("llave"):
		_abrir(null)
		return true
	return false

func _abrir(jugador):
	abierta = true
	if jugador and jugador.objeto_en_mano != null:
		jugador.objeto_en_mano.queue_free()
		jugador.objeto_en_mano = null
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", rotation.y + deg_to_rad(90), 0.6)
	print("Puerta con llave abierta")
