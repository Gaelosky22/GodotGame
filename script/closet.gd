extends Node3D

# ─── CLOSET ────────────────────────────────────────────────────────────────
# Estructura del nodo en el editor:
#   Closet (Node3D)  ← este script
#     MeshInstance3D
#     Area3D
#       CollisionShape3D  (BoxShape ajustado al interior del closet)
#
# Diferencia con la cama: la cámara NO baja, se queda a la misma altura.
# El jugador solo queda bloqueado (sin moverse) mientras está adentro.

func _ready():
	var area = get_node_or_null("MeshInstance3D/Area3D")
	if area == null:
		push_error("closet.gd: no se encontró nodo Area3D hijo. Agrégalo en el editor.")
		return
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if not body.is_in_group("jugador"):
		return
	body.puede_esconderse = true
	# Informar al jugador que el escondite cercano es tipo CLOSET
	body.tipo_escondite_cercano = body.TipoEscondite.CLOSET

func _on_body_exited(body):
	if not body.is_in_group("jugador"):
		return
	body.puede_esconderse = false
	body.tipo_escondite_cercano = body.TipoEscondite.NINGUNO
	if body.escondido:
		body.escondido = false
		body.bloqueado = false
		var tween = body.create_tween()
		tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(body.camara, "position", body.posicion_normal, 0.5)
		tween.parallel().tween_property(body.camara, "rotation", Vector3(0, 0, 0), 0.5)
