extends Node3D

@export var punto_activacion: Vector3 = Vector3(-4.836955, 1.019905, -33.8899)
@export var rango_activacion: float = 3.0
@export var velocidad_correr: float = 14.0

var jugador: Node3D = null
var activada: bool = false
var persiguiendo: bool = false

var anim: AnimationPlayer = null
@onready var audio_jumpscare: AudioStreamPlayer3D = $AudioJumpscare

func _ready():
	anim = _buscar_anim(self)
	add_to_group("viejita")
	var jugadores = get_tree().get_nodes_in_group("jugador")
	if jugadores.size() > 0:
		jugador = jugadores[0]
	_mirar_a(Vector3(-1.640001, global_position.y, -33.99056))

func _buscar_anim(nodo: Node) -> AnimationPlayer:
	if nodo is AnimationPlayer:
		return nodo
	for hijo in nodo.get_children():
		var r = _buscar_anim(hijo)
		if r: return r
	return null

func _process(delta):
	if activada or jugador == null:
		if persiguiendo:
			_perseguir(delta)
		return
	
	var dist_jugador = global_position.distance_to(jugador.global_position)
	if dist_jugador < 20.0:
		_mirar_a(jugador.global_position)
	
	var dist_activacion = Vector2(
		jugador.global_position.x - punto_activacion.x,
		jugador.global_position.z - punto_activacion.z
	).length()
	
	if dist_activacion < rango_activacion:
		_activar()

func _activar():
	if activada: return
	activada = true
	persiguiendo = true
	
	_reproducir("Armature|RunFast|baselayer")
	if audio_jumpscare:
		audio_jumpscare.play()

func _perseguir(delta):
	if jugador == null:
		queue_free()
		return
	
	var dir = jugador.global_position - global_position
	dir.y = 0
	if dir.length() > 0.2:
		dir = dir.normalized()
		# Movimiento directo sin physics
		global_position += dir * velocidad_correr * delta
		_mirar_a(jugador.global_position)
	
	if audio_jumpscare and not audio_jumpscare.playing and persiguiendo:
		await get_tree().process_frame
		queue_free()

func _mirar_a(pos: Vector3):
	var dir = pos - global_position
	dir.y = 0
	if dir.length() > 0.1:
		look_at(global_position + dir.normalized(), Vector3.UP)
		rotation.y += PI


func _reproducir(nombre: String):
	if anim == null: return
	if anim.has_animation(nombre):
		anim.play(nombre, -1, 1.0, false)
