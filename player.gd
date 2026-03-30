extends CharacterBody2D

var SPEED : float = 165.0
#const ACCELERATION : float = 1000.0
const JUMP_VELOCITY : float = -300.0
var availible_jumps : int = 3
var direction : int = 1
const box = preload("res://box.tscn")
const nailbreaker = preload("res://nailbreaker.tscn")
const Enemy = preload("res://enemy.tscn")
const RL = preload("res://weapons/RL/rl_pickable.tscn")
const shotgun = preload("res://weapons/Shotgun/shotgun_pickable.tscn")

var is_sliding : bool = false
var is_slamming : bool = false

@onready var steps: AudioStreamPlayer2D = $steps
@onready var wall_slide_loop: AudioStreamPlayer2D = $wall_slide_loop
@onready var wind: AudioStreamPlayer2D = $wind

func _ready() -> void:
	GlobalVars.player = self

func _physics_process(delta: float) -> void:
	if is_on_wall_only() and (not is_on_floor()) and velocity.y > 0 and\
	(Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		is_sliding = true
		velocity.y += get_gravity().y * delta * 0.1 # скользим по стенам
	elif not is_on_floor():
		is_sliding = false
		velocity.y += get_gravity().y * delta # базовое падение
	else:
		is_sliding = false
	
	if is_sliding and GlobalVars.player_hp > 0:
		wall_slide_loop.volume_db = 0.0
	else:
		wall_slide_loop.volume_db = -80.0
	
	var previous_velocity = velocity
	
	if GlobalVars.player_hp > 0:
		wind_ambient()
		get_input(delta)
		fall()
		move_and_slide()

	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var normal = collision.get_normal()
			collider.apply_central_impulse(previous_velocity * normal * -0.15)

func _process(_delta: float) -> void:
	jump()
	if Input.is_action_just_pressed("spawn_BOX"):
		var new_box = box.instantiate()
		new_box.global_position = get_global_mouse_position()
		get_parent().add_child(new_box)
	elif Input.is_action_just_pressed("spawn_NAILBREAKER"):
		var new_nailbreaker = nailbreaker.instantiate()
		new_nailbreaker.global_position = get_global_mouse_position()
		get_parent().add_child(new_nailbreaker)
	elif Input.is_action_just_pressed("spawn_RL"):
		var new_RL = RL.instantiate()
		new_RL.global_position = get_global_mouse_position()
		get_parent().add_child(new_RL)
	elif Input.is_action_just_pressed("spawn_ENEMY"):
		var new_enemy = Enemy.instantiate()
		new_enemy.global_position = get_global_mouse_position()
		get_parent().add_child(new_enemy)
		new_enemy.name = "Enemy" + str(GlobalVars.killed)
	elif Input.is_action_just_pressed("spawn_SHOTGUN"):
		print("SHOTGUN")
		var new_shotgun = shotgun.instantiate()
		new_shotgun.global_position = get_global_mouse_position()
		get_parent().add_child(new_shotgun)


func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		if $AnimationPlayer.current_animation == "slam_stop":
			$AnimationPlayer.play("RESET")
	elif $Timer.time_left > 0 and Input.is_action_just_pressed("jump"):
		velocity.y += JUMP_VELOCITY
		if $AnimationPlayer.current_animation == "slam_stop":
			$AnimationPlayer.play("RESET")
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		velocity.y *= 0.6
	elif Input.is_action_just_pressed("jump") and is_on_wall_only() and availible_jumps > 0:
		if is_slamming:
			is_slamming = false
			$AnimationPlayer.stop()
		velocity.x = sign(get_wall_normal().x) * 200
		velocity.y = -350
		availible_jumps -= 1
	if is_on_floor():
		availible_jumps = 3
		$Timer.start()

func fall():
	if position.y > 10000:
		respawn()
		#position.y = 233
		#position.x = 233
		#velocity = Vector2(0, 0)
		is_sliding = false
		is_slamming = false
		$Camera2D.reset_smoothing()
		$AnimationPlayer.play("RESET")

func wind_ambient():
	if not is_on_floor() and not is_on_ceiling():
		wind.volume_db = min((abs(velocity.x) + abs(velocity.y)) * 0.025 - 35, 7.5)
		wind.pitch_scale = (velocity.x + velocity.y) * 0.0001 + 1.0
	else:
		wind.volume_db = -80

func animation_finished(anim_name: StringName) -> void:
	if anim_name == "slam_start" and is_on_floor():
		$AnimationPlayer.play("slam_stop")

func push(pwr, _dir):
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		velocity += pwr * Vector2(-1, -1) / 2
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		velocity += pwr * Vector2(1, -1) / 2
	else:
		velocity += pwr * _dir / 2
	GlobalVars.damage(pwr / 100)

func get_input(delta: float) -> void:
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		direction = -1
		if sign(velocity.x) != direction:
			velocity.x *= 0.8
		velocity.x += (SPEED - abs(velocity.x)) * direction * delta * 5
	if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		direction = 1
		if sign(velocity.x) != direction:
			velocity.x *= 0.8
		velocity.x += (SPEED - abs(velocity.x)) * direction * delta * 10
	if not steps.is_playing() and is_on_floor() and abs(round(velocity.x)) > 10:
			steps.play()
	if Input.is_action_just_pressed("slam") and not is_on_floor() and not Input.is_action_just_pressed("jump"):
		$AnimationPlayer.play("slam_start")
		velocity.y = 750
		velocity.x = 0
		is_slamming = true
	elif is_slamming and is_on_floor():
		$AnimationPlayer.play("slam_stop")
		is_slamming = false
	elif is_slamming and is_sliding:
		$AnimationPlayer.stop()
		is_slamming = false
	if int(Input.is_action_pressed("move_left")) == int(Input.is_action_pressed("move_right")):
		if is_on_floor():
			velocity.x *= 0.8
		else:
			velocity.x *= 0.99
	
	if Input.is_action_just_pressed("item1"):
		GlobalVars.current_item = GlobalVars.items.item1
		GlobalVars.current_slot = "item1"
		if GlobalVars.current_item == "nothing":
			$Camera2D.position_smoothing_speed = 2
		else:
			$Camera2D.position_smoothing_speed = 10
	elif Input.is_action_just_pressed("item2"):
		GlobalVars.current_item = GlobalVars.items.item2
		GlobalVars.current_slot = "item2"
		if GlobalVars.current_item == "nothing":
			$Camera2D.position_smoothing_speed = 2
		else:
			$Camera2D.position_smoothing_speed = 10
	elif Input.is_action_just_pressed("item3"):
		GlobalVars.current_item = GlobalVars.items.item3
		GlobalVars.current_slot = "item3"
		if GlobalVars.current_item == "nothing":
			$Camera2D.position_smoothing_speed = 2
		else:
			$Camera2D.position_smoothing_speed = 10
	
	if Input.is_action_pressed("zoom_in"):
		$Camera2D.zoom.x = min($Camera2D.zoom.x + 0.3 * delta, 1.0)
		$Camera2D.zoom.y = min($Camera2D.zoom.y + 0.3 * delta, 1.0)
	elif Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom.x = max($Camera2D.zoom.x - 0.3 * delta, 0.4)
		$Camera2D.zoom.y = max($Camera2D.zoom.y - 0.3 * delta, 0.4)
	
	if Input.is_action_just_pressed("respawn"):
		respawn()

func respawn():
	is_slamming = false
	is_sliding = false
	velocity = Vector2(0, 0)
	global_position = Vector2(150, 145)
	$Camera2D.global_position = global_position
	GlobalVars.player_hp = 100
	$Camera2D.reset_smoothing()
	$AnimationPlayer.play("RESET")
func show_damage():
	$blood.emitting = true
