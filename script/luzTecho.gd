extends SpotLight3D

@export var energia_normal := 2.0

func _ready():
	light_energy = energia_normal
	parpadeo()

func parpadeo():
	while true:
		await get_tree().create_timer(randf_range(2.0, 4.0)).timeout
		
		var cantidad = randi_range(1, 5)
		
		for i in cantidad:
			light_energy = 0.0
			await get_tree().create_timer(randf_range(0.03, 0.12)).timeout
			
			light_energy = energia_normal
			await get_tree().create_timer(randf_range(0.03, 0.10)).timeout
