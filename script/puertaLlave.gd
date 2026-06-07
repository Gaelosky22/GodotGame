extends Node3D

var abierta = false
var jugador_ref = null

func _ready():
	
	add_to_group("puertas_llave")
	if GameState.puerta_llave_abierta:
		abierta = true
		rotation.y += deg_to_rad(-90)
	var area = get_node_or_null("MeshInstance3D/Area3D")
	if area == null:
		push_error("puertaLlave: no se encontró MeshInstance3D/Area3D")
		return
	area.body_entered.connect(_on_jugador_entra)
	area.body_exited.connect(_on_jugador_sale)

func _on_jugador_entra(body):
	if body.is_in_group("jugador"):
		jugador_ref = body
		body.puerta_cercana = self

func _on_jugador_sale(body):
	if body.is_in_group("jugador"):
		if body.puerta_cercana == self:
			body.puerta_cercana = null
		jugador_ref = null

func interactuar():
	print("interactuar llamado, abierta=", abierta, " jugador_ref=", jugador_ref)
	if abierta or jugador_ref == null:
		return
	print("objeto en mano=", jugador_ref.objeto_en_mano)
	if jugador_ref.objeto_en_mano != null:
		print("nombre=", jugador_ref.objeto_en_mano.nombre_display)
	if abierta or jugador_ref == null:
		return
	if jugador_ref.objeto_en_mano != null and jugador_ref.objeto_en_mano.nombre_display.to_lower().contains("llave"):
		_abrir()
	else:
		jugador_ref.mostrar_mensaje_temporal("No se puede abrir, falta algo...", 3.0)

func _abrir():
	abierta = true
	GameState.marcar_puerta_llave()
	var llave = jugador_ref.objeto_en_mano
	jugador_ref.objeto_en_mano = null
	llave.queue_free()
	jugador_ref.mostrar_mensaje_temporal("¡Puerta abierta!", 1.5)
	var tween = create_tween()
	tween.tween_property(self, "rotation:y", rotation.y + deg_to_rad(-90), 1.7)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	var enemigo = get_tree().get_root().find_child("enemigo", true, false)
	if enemigo and enemigo.has_method("notificar_objetivo_completado"):
		enemigo.notificar_objetivo_completado()
