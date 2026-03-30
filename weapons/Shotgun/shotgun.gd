extends Node2D

@onready var Sprite : Sprite2D = $Sprite2D
@onready var Spawnpoint : Marker2D = $Sprite2D/spawnpoint
@onready var Cooldown : Timer = $cooldown
@onready var Shapecast : ShapeCast2D = $Sprite2D/ShapeCast2D

const BULLET = preload("uid://csr8w1qcnqlbd")
var my_slot : String = ""
var can_shoot : bool = true
var is_friendly : bool = false
var weapon_owner : String = ""
var current_angle = null
var is_player_nearby : bool = false

func _process(delta: float) -> void:
	match weapon_owner:
		"Player":
			if GlobalVars.current_slot == my_slot:
				visible = true
				logic(delta)
			else:
				visible = false
		"Enemy":
			if Shapecast.is_colliding() and Shapecast.get_collider(1) == GlobalVars.player and can_shoot:
				is_player_nearby = true
			else:
				is_player_nearby = false
			logic(delta)

func logic(delta):
	if weapon_owner == "Player":
		Sprite.rotation = lerp_angle(Sprite.rotation, (get_global_mouse_position()\
		- global_position).angle(), 18 * delta)
		current_angle = (get_global_mouse_position() - global_position).normalized().angle()
	elif weapon_owner == "Enemy":
		Sprite.rotation = lerp_angle(Sprite.rotation, (GlobalVars.player.global_position\
		- global_position).angle(), 18 * delta)
		current_angle = (GlobalVars.player.global_position - global_position).normalized().angle()
	
	if -1.5 <= current_angle and current_angle <= 1.5:
		Sprite.scale.y = 1
	else:
		Sprite.scale.y = -1
	
	if Input.is_action_just_pressed("lmb") and can_shoot and weapon_owner == "Player":
		shoot()

func shoot():
	for x in range(5):
		var new_bullet = BULLET.instantiate()
		new_bullet.damage_amount = 3
		new_bullet.is_friendly = is_friendly
		new_bullet.global_position = Spawnpoint.global_position
		new_bullet.global_rotation = Sprite.global_rotation + randf_range(-0.1, 0.1)
		get_node("/root/main").add_child(new_bullet)
	can_shoot = false
	Cooldown.start()

func _on_cooldown_timeout() -> void:
	can_shoot = true
