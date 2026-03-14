extends Node2D

const rocket_scene = preload("res://rocket.tscn")

@onready var RotationOffset: Node2D = $RotationOffset
@onready var ShootPos: Marker2D = $RotationOffset/RL_sprite/shoot_pos

var time_between_shot: float = 0.5
var can_shoot: bool = true
var current_angle: float = 0.0

func _ready() -> void:
	current_angle = (get_global_mouse_position() - global_position).normalized().angle()
	$ShootTimer.wait_time = time_between_shot

func _physics_process(delta: float) -> void:
	if GlobalVars.current_item == "RL":
		visible = true
		RL_logic(delta)
	else:
		visible = false

func RL_logic(delta):
	RotationOffset.rotation = lerp_angle(RotationOffset.rotation, (get_global_mouse_position() - global_position).angle(), 20 * delta)

	current_angle = (get_global_mouse_position() - global_position).normalized().angle()
	if -1.5 <= current_angle and current_angle <= 1.5:
		$RotationOffset/RL_sprite.scale.y = 0.375
	else:
		$RotationOffset/RL_sprite.scale.y = -0.375
	global_position = get_node("/root/main/Player").global_position

	if Input.is_action_just_pressed("lmb") and can_shoot:
		can_shoot = false
		$ShootTimer.start()
		shoot()

func shoot():
	var new_rocket = rocket_scene.instantiate()
	new_rocket.global_position = ShootPos.global_position
	new_rocket.global_rotation = ShootPos.global_rotation
	get_parent().add_child(new_rocket)


func _on_shoot_timer_timeout() -> void:
	can_shoot = true
