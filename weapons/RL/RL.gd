extends Node2D

const ROCKET = preload("uid://cfex0tmkaj6q4")

@onready var Sprite : Node2D = $RL_sprite
@onready var ShootPos : Marker2D = $RL_sprite/shoot_pos
@onready var Cooldown : Timer = $cooldown
@onready var Shapecast : ShapeCast2D = $RL_sprite/ShapeCast2D

var is_player_nearby : bool = false
var my_slot : String = ""
var can_shoot: bool = true
var current_angle: float = 0.0
var weapon_owner : String = ""
var is_friendly : bool = false
var is_player_colliding : bool = false

func _process(delta: float) -> void:
	match weapon_owner:
		"Player":
			if GlobalVars.current_slot == my_slot:
				visible = true
				RL_logic(delta)
			else:
				visible = false
		"Enemy":
			if is_player_colliding and can_shoot:
				is_player_nearby = true
			else:
				is_player_nearby = false
			RL_logic(delta)

func RL_logic(delta):
	if weapon_owner == "Player":
		Sprite.rotation = lerp_angle(Sprite.rotation, (get_global_mouse_position()\
		- global_position).angle(), 20 * delta)
		current_angle = (get_global_mouse_position() - global_position).normalized().angle()
	elif weapon_owner == "Enemy":
		Sprite.rotation = lerp_angle(Sprite.rotation, (GlobalVars.player.global_position\
		- global_position).angle(), 20 * delta)
		current_angle = (GlobalVars.player.global_position - global_position).normalized().angle()
	
	if -1.5 <= current_angle and current_angle <= 1.5:
		Sprite.scale.y = 0.375
	else:
		Sprite.scale.y = -0.375

	if Input.is_action_just_pressed("lmb") and can_shoot and weapon_owner == "Player":
		shoot(25)

func shoot(damage_amount):
	var new_rocket = ROCKET.instantiate()
	new_rocket.global_position = ShootPos.global_position
	new_rocket.global_rotation = ShootPos.global_rotation
	new_rocket.damage_amount = damage_amount
	get_node("/root/main").add_child(new_rocket)
	
	can_shoot = false
	Cooldown.start()

func _on_cooldown_timeout() -> void:
	can_shoot = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		is_player_colliding = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == GlobalVars.player:
		is_player_colliding = false
