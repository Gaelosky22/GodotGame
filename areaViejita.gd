extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("jugador"):
		get_parent().get_parent().global_position = Vector3(99, 99, 99)
