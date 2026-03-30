extends RigidBody2D

@onready var player = GlobalVars.player

const shotgun = preload("uid://bsecy8dw60b21")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if visible and "Player" in str(body):
		for x in GlobalVars.items:
			if "nothing" in GlobalVars.items[x]:
				collision_layer = 16
				$Sprite2D.self_modulate.a = 0.0
				GlobalVars.items[x] = "shotgun"
				var new_shotgun = shotgun.instantiate()
				new_shotgun.weapon_owner = "Player"
				new_shotgun.is_friendly = true
				player.add_child(new_shotgun)
				new_shotgun.my_slot = x
				$pickup.play()
				break

func push(pwr, dir):
	linear_velocity += dir * pwr

func _on_pickup_finished() -> void:
	queue_free()
