extends RigidBody2D

@onready var player = GlobalVars.player

const RL = preload("uid://brcehntt6lxn6")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if visible and "Player" in str(body):
		for x in GlobalVars.items:
			if "nothing" in GlobalVars.items[x]:
				collision_layer = 16
				$Sprite2D.self_modulate.a = 0.0
				GlobalVars.items[x] = "RL"
				var new_RL = RL.instantiate()
				new_RL.weapon_owner = "Player"
				player.add_child(new_RL)
				new_RL.my_slot = x
				$pickup.play()
				break

func push(pwr, dir):
	linear_velocity += dir * pwr

func _on_pickup_finished() -> void:
	queue_free()
