extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var chirrido = $AudioStreamPlayer3D
@onready var audio_ambiente = get_node_or_null("../musicaFondo")
var abierta = false
var nombre_animacion = "puertaRotacion"

func _ready():
	anim.stop()

func interactuar():
	print("Intentando reproducir:", nombre_animacion)

	if anim.is_playing():
		return

	abierta = !abierta

	if abierta:
		anim.play(nombre_animacion)
		chirrido.play()
		
	else:
		anim.play_backwards(nombre_animacion)
	
	var enemigo = get_tree().get_root().find_child("enemigo", true, false)
	if enemigo and enemigo.has_method("escuchar_puerta"):
		enemigo.escuchar_puerta(global_position)
