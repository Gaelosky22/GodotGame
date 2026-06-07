extends Node3D

@export var nombre_display: String = "Objeto"
@export var es_pesado: bool = false
var agarrado = false
var posicion_original: Vector3
var rotacion_original: Vector3

func _ready():
	if nombre_display.to_lower().contains("llave") and GameState.llave_recogida:
		queue_free()
		return
	if GameState.galon_fue_recogido(name):
		queue_free()
		return
	add_to_group("objetos_recogibles")
	posicion_original = global_position
	rotacion_original = rotation
	var area = Area3D.new()
	area.name = "AreaDeteccion"
	add_child(area)
	var shape = CollisionShape3D.new()
	var esfera = SphereShape3D.new()
	esfera.radius = 75.0
	shape.shape = esfera
	area.add_child(shape)
	area.body_entered.connect(_on_jugador_cerca)
	area.body_exited.connect(_on_jugador_lejos)

func _on_jugador_cerca(body):
	if body.is_in_group("jugador") and not agarrado:
		body.registrar_objeto_cercano(self)

func _on_jugador_lejos(body):
	if body.is_in_group("jugador"):
		body.limpiar_objeto_cercano(self)

func agarrar(camara: Node3D):
	agarrado = true
	if has_node("AreaDeteccion"):
		get_node("AreaDeteccion").monitoring = false
	var padre_original = get_parent()
	padre_original.remove_child(self)
	camara.add_child(self)
	position = Vector3(0.35, -0.3, -0.6)
	rotation = Vector3(0, 0, 0)

func soltar():
	agarrado = false
	var camara = get_parent()
	var escena = camara.get_tree().current_scene
	var pos_global = camara.global_position + camara.global_transform.basis.z * 1.2
	camara.remove_child(self)
	escena.add_child(self)
	global_position = pos_global
	rotation = Vector3(0, 0, 0)
	var espacio = escena.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.DOWN * 10.0
	)
	query.exclude = [self]
	var resultado = espacio.intersect_ray(query)
	if resultado:
		global_position = resultado.position + Vector3.UP * 0.1
	if has_node("AreaDeteccion"):
		get_node("AreaDeteccion").monitoring = true
