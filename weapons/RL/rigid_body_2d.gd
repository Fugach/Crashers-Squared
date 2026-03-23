extends RigidBody2D


const RL = preload("uid://brcehntt6lxn6")

@onready var player = get_node("/root/main/Player")
func _ready() -> void:
	pass
func _on_area_2d_body_entered(body: Node2D) -> void:
	if visible and "Player" in str(body):
		for x in GlobalVars.items:
			if "nothing" in GlobalVars.items[x]:
				$CollisionShape2D.set_deferred("freeze", true)
				# TODO: отключить нормально коллизию
				visible = false
				$pickup.play()
				GlobalVars.items[x] = "RL"
				var new_RL = RL.instantiate()
				player.add_child(new_RL)
				await $pickup.finished
				print(GlobalVars.items)
				queue_free()
				break
func push(pwr, dir):
	linear_velocity += dir * pwr
