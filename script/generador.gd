extends Node3D

@export var id_generador: int = 1

var tiene_gasolina = false
var encendido = false
var cargando = false

# Agrega un AudioStreamPlayer3D hijo llamado "AudioGenerador" con tu audio de generador
# Agrega otro AudioStreamPlayer3D hijo llamado "AudioEcharGas" con res://sonidos/echar gas.mp3
@onready var audio_generador = get_node_or_null("AudioGenerador")
@onready var audio_echar_gas = get_node_or_null("AudioEcharGas")

func _ready():
	add_to_group("generadores")
	print("Generador '", name, "' iniciando. GameState dice encendido: ", GameState.generador_fue_encendido(name))
	print("GameState completo: ", GameState.generadores_encendidos)
	if GameState.generador_fue_encendido(name):
		tiene_gasolina = true
		encendido = true
		if audio_generador:
			audio_generador.volume_db = -18.0
			_loop_audio_generador()

func recibir_objeto(objeto) -> bool:
	if encendido:
		_mostrar_mensaje("¡Ya está activado!")
		return false
	if cargando:
		return false
	if not objeto.nombre_display.to_lower().contains("gal"):
		return false
	cargando = true
	GameState.marcar_galon(objeto.name)
	GameState.marcar_generador(name)  # ← marcar ANTES del await
	objeto.queue_free()
	if audio_echar_gas:
		audio_echar_gas.play()
	_mostrar_mensaje("Cargando gasolina...")
	await get_tree().create_timer(6.0).timeout
	if not is_inside_tree(): return true
	if audio_echar_gas and audio_echar_gas.playing:
		audio_echar_gas.stop()
	_encender()
	return true
	
func _encender():
	print("Guardando generador: '", name, "'")
	print("GameState antes: ", GameState.generadores_encendidos)
	GameState.marcar_generador(name)
	print("GameState despues: ", GameState.generadores_encendidos)
	tiene_gasolina = true
	encendido = true
	cargando = false
	GameState.marcar_generador(name)
	MisionHUD.actualizar()
	_mostrar_mensaje("¡Generador activado!")
	print("Generador ", id_generador, " encendido")
	if audio_generador:
		audio_generador.volume_db = -18.0
		_loop_audio_generador()
	var enemigo = get_tree().get_first_node_in_group("enemigo")
	if enemigo and enemigo.has_method("activar_generador"):
		enemigo.activar_generador(id_generador)

func _loop_audio_generador():
	if not encendido or not is_inside_tree(): return
	if audio_generador:
		audio_generador.play()
	await get_tree().create_timer(5.0).timeout
	if is_inside_tree():
		_loop_audio_generador()

func _mostrar_mensaje(texto: String):
	# Buscar label de interacción del jugador
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.is_empty(): return
	var jugador = jugadores[0]
	if jugador.has_method("mostrar_mensaje_temporal"):
		jugador.mostrar_mensaje_temporal(texto)
	else:
		print(texto)
