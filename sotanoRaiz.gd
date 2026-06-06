extends Node3D

func _ready():
	if PlayerSpawn.tiene_spawn:
		$Jugador.global_position = PlayerSpawn.consumir()
	
	# Fade de negro a transparente al aparecer
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 1)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var capa = CanvasLayer.new()
	capa.layer = 99
	add_child(capa)
	capa.add_child(fade)
	
	var tween = create_tween()
	tween.tween_property(fade, "color", Color(0, 0, 0, 0), 0.8)
	await tween.finished
	capa.queue_free()
