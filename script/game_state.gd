extends Node

var llave_recogida = false
var puerta_llave_abierta = false
var galones_recogidos = {}    # {"Galon1": true, "Galon2": true}
var generadores_encendidos = {}  # {"Generador1": true, ...}
var puerta_generador_abierta = false
var cables_reparados = false
var mono_susto_hecho := false
func marcar_llave():
	llave_recogida = true

func marcar_galon(nombre: String):
	galones_recogidos[nombre] = true

func galon_fue_recogido(nombre: String) -> bool:
	return galones_recogidos.get(nombre, false)

func marcar_generador(nombre: String):
	generadores_encendidos[nombre] = true

func generador_fue_encendido(nombre: String) -> bool:
	return generadores_encendidos.get(nombre, false)

func marcar_puerta_llave():
	puerta_llave_abierta = true

func marcar_puerta_generador():
	puerta_generador_abierta = true

func marcar_cables():
	cables_reparados = true

func reset():
	llave_recogida = false
	puerta_llave_abierta = false
	galones_recogidos = {}
	generadores_encendidos = {}
	puerta_generador_abierta = false
	cables_reparados = false
