extends RigidBody2D


const RL = preload("uid://brcehntt6lxn6")

@onready var player = get_node("/root/main/Player")

func _ready() -> void:
	pass
func _on_area_2d_body_entered(body: Node2D) -> void:
	if visible and "Player" in str(body):
		for x in GlobalVars.items:
			if "nothing" in GlobalVars.items[x]:
				collision_layer = 16
				# TODO: отключить нормально коллизию
				$Sprite2D.self_modulate.a = 0.0
				GlobalVars.items[x] = "RL"
				var new_RL = RL.instantiate()
				player.add_child(new_RL)
				print(x)
				new_RL.my_slot = x
				$pickup.play()
				break
func push(pwr, dir):
	linear_velocity += dir * pwr
func _on_pickup_finished() -> void:
	queue_free()
