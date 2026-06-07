# basura.gd
extends Node3D

func _ready():
	var area = get_node_or_null("Area3D")
	if area == null:
		push_error("basura.gd: no se encontró Area3D")
		return
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if not body.is_in_group("jugador"):
		return
	body.puede_esconderse = true
	body.tipo_escondite_cercano = body.TipoEscondite.BASURA

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
