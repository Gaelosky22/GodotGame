extends Node3D

@export var velocidad: float = 8.5
@export var destino_z: float = -70.0

var moviendose := false
var anim: AnimationPlayer

func _ready():
	anim = _buscar_anim(self)

func _process(delta):
	if not moviendose:
		return

	# Mantener animación de correr
	if anim and not anim.is_playing():
		anim.play("thc4_arma|st_run")

	# Movimiento
	global_position.z -= velocidad * delta

	# Llegó al destino
	if global_position.z <= destino_z:
		moviendose = false

func activar():
	if moviendose:
		return

	moviendose = true

	if anim:
		anim.play("thc4_arma|st_run")

func _buscar_anim(nodo: Node) -> AnimationPlayer:
	if nodo is AnimationPlayer:
		return nodo

	for hijo in nodo.get_children():
		var resultado = _buscar_anim(hijo)
		if resultado:
			return resultado

	return null
