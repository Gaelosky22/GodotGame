extends Node

var spawn_position: Vector3 = Vector3.ZERO
var tiene_spawn: bool = false

func set_spawn(pos: Vector3):
	spawn_position = pos
	tiene_spawn = true

func consumir() -> Vector3:
	tiene_spawn = false
	return spawn_position
