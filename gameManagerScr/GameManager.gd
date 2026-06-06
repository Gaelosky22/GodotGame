extends Node

# --- Posición de spawn al cambiar escena ---
var spawn_position: Vector3 = Vector3.ZERO
var spawn_set: bool = false

# --- Estado persistente por escena ---
var sotano_state: Dictionary = {}
var segundo_piso_state: Dictionary = {}

func save_scene_state(scene_name: String, data: Dictionary):
	if scene_name == "sotano":
		sotano_state = data
	elif scene_name == "escenaSegundoPiso":
		segundo_piso_state = data

func get_scene_state(scene_name: String) -> Dictionary:
	if scene_name == "sotano":
		return sotano_state
	elif scene_name == "escenaSegundoPiso":
		return segundo_piso_state
	return {}

func go_to_scene(scene_path: String, spawn_pos: Vector3):
	spawn_position = spawn_pos
	spawn_set = true
	get_tree().change_scene_to_file(scene_path)
