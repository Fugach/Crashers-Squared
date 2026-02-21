extends RigidBody2D

@onready var player = GlobalVars.player
var is_touching_cursor : bool = false
var is_grabbed : bool = false
func _process(delta: float) -> void:
	if player != null and global_position.distance_to(player.global_position) < 100 and is_touching_cursor and\
	Input.is_action_just_pressed("interact") and\
	get_global_mouse_position().distance_to(player.global_position) < 100:
		is_grabbed = true
	elif player != null and global_position.distance_to(player.global_position) > 125 and is_grabbed:
		is_grabbed = false
	elif player != null and is_grabbed and Input.is_action_just_pressed("interact"):
		is_grabbed = false
	
	if is_grabbed:
		linear_velocity.x = (global_position.x - get_global_mouse_position().x) * -2
		print((global_position - get_global_mouse_position()) * -25)
		linear_velocity.y = (global_position.y - get_global_mouse_position().y) * -2
func push(pwr, dir):
	linear_velocity += dir * pwr


func _on_control_mouse_entered():
	is_touching_cursor = true


func _on_control_mouse_exited():
	is_touching_cursor = false
