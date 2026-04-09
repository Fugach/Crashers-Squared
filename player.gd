extends CharacterBody2D

var SPEED : float = 165.0
#const ACCELERATION : float = 1000.0
const JUMP_VELOCITY : float = -300.0
var availible_jumps : int = 3
var direction : int = 1

const Enemy = preload("res://enemy.tscn")
const RL = preload("res://weapons/RL/rl_pickable.tscn")
const shotgun = preload("res://weapons/Shotgun/shotgun_pickable.tscn")
const pistol = preload("uid://5j581geyyouk")

@onready var SlotsHUD: Node2D = $"../UI/HUD/Slots"


var is_sliding : bool = false
var is_slamming : bool = false
var throw_power : Vector2 = Vector2(-10000, -10000)

@onready var main: Node2D = $".."
@onready var steps: AudioStreamPlayer2D = $steps
@onready var wall_slide_loop: AudioStreamPlayer2D = $wall_slide_loop
@onready var wind: AudioStreamPlayer2D = $wind

func _ready() -> void:
	GlobalVars.player = self

func _physics_process(delta: float) -> void:
	if is_on_wall_only() and (not is_on_floor()) and velocity.y > 0 and\
	(Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		is_sliding = true
		$SlideCoyote.start()
		
		if randi_range(1, 8) == 6:
			$slide.global_position = global_position + Vector2(5 * direction, 5)
			$slide.scale.x = direction * -1
			$slide.amount = 5 + int(velocity.y / 100)
			$slide.emitting = true
		
		velocity.y += get_gravity().y * delta * 0.1 # скользим по стенам
	elif not is_on_floor():
		$slide.emitting = false
		velocity.y += get_gravity().y * delta # базовое падение
	else:
		$slide.emitting = false
	
	if is_sliding and GlobalVars.player_hp > 0:
		wall_slide_loop.volume_db = 0.0
		wall_slide_loop.pitch_scale = 1.0 + velocity.y / 100
	else:
		wall_slide_loop.volume_db = -80.0
	
	var previous_velocity = velocity
	
	if GlobalVars.player_hp > 0:
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
	if Input.is_action_just_pressed("spawn_RL"):
		var new_RL = RL.instantiate()
		new_RL.global_position = get_global_mouse_position()
		get_parent().add_child(new_RL)
	elif Input.is_action_just_pressed("spawn_ENEMY"):
		var new_enemy = Enemy.instantiate()
		new_enemy.global_position = get_global_mouse_position()
		get_parent().add_child(new_enemy)
		new_enemy.name = "Enemy" + str(GlobalVars.killed)
	elif Input.is_action_just_pressed("spawn_SHOTGUN"):
		var new_shotgun = shotgun.instantiate()
		new_shotgun.global_position = get_global_mouse_position()
		get_parent().add_child(new_shotgun)
	elif Input.is_action_just_pressed("spawn_PISTOL"):
		var new_pistol = pistol.instantiate()
		new_pistol.global_position = get_global_mouse_position()
		get_parent().add_child(new_pistol)


func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		if $AnimationPlayer.current_animation == "slam_stop":
			$AnimationPlayer.play("RESET")
	elif $Coyote.time_left > 0 and Input.is_action_just_pressed("jump"):
		velocity.y += JUMP_VELOCITY
		if $AnimationPlayer.current_animation == "slam_stop":
			$AnimationPlayer.play("RESET")
	if Input.is_action_just_released("jump") and not is_on_floor() and velocity.y < 0:
		velocity.y *= 0.6
	elif Input.is_action_just_pressed("jump") and is_sliding and availible_jumps > 0:
		if is_slamming:
			is_slamming = false
			$AnimationPlayer.stop()
		velocity.x = sign(get_wall_normal().x) * 200
		velocity.y = -350
		availible_jumps -= 1
	if is_on_floor():
		availible_jumps = 3
		$Coyote.start()

func fall():
	if not is_on_floor() and not is_on_ceiling():
		wind.volume_db = min((abs(velocity.x) + abs(velocity.y)) * 0.025 - 35, 7.5)
		wind.pitch_scale = (velocity.x + velocity.y) * 0.0001 + 1.0
	else:
		wind.volume_db = -80
	
	if position.y > 10000:
		respawn()
		is_sliding = false
		is_slamming = false
		$Camera2D.reset_smoothing()
		$AnimationPlayer.play("RESET")

func push(pwr, _dir):
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		velocity += pwr * Vector2(-1, -1) / 2
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		velocity += pwr * Vector2(1, -1) / 2
	else:
		velocity += pwr * _dir / 2

func damage(amount):
	GlobalVars.player_hp -= amount

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
	if $AnimationPlayer.current_animation == "slam_stop" and Input.is_action_just_pressed("jump"):
		velocity.y += JUMP_VELOCITY * 0.3
	
	if int(Input.is_action_pressed("move_left")) == int(Input.is_action_pressed("move_right")):
		if is_on_floor():
			velocity.x *= 0.8
		else:
			velocity.x *= 0.99
	
	if Input.is_action_just_pressed("slot1"):
		GlobalVars.current_slot_num = "slot1"
		SlotsHUD.update()
	elif Input.is_action_just_pressed("slot2"):
		GlobalVars.current_slot_num = "slot2"
		SlotsHUD.update()
	elif Input.is_action_just_pressed("slot3"):
		GlobalVars.current_slot_num = "slot3"
		SlotsHUD.update()
	
	if Input.is_action_just_pressed("throw_item"):
		var item : Node2D = GlobalVars.slots[GlobalVars.current_slot_num]
		if item != null:
			$throw.play()
			match item.name.left(-6):
				"Shotgun":
					var new_shogun = shotgun.instantiate()
					new_shogun.global_position = global_position + Vector2(0, -15)
					new_shogun.apply_force(throw_power * Vector2(sign(global_position.x - get_global_mouse_position().x), 1))
					get_parent().add_child(new_shogun)
				"RL":
					var new_RL = RL.instantiate()
					new_RL.global_position = global_position + Vector2(0, -15)
					new_RL.apply_force(throw_power * Vector2(sign(global_position.x - get_global_mouse_position().x), 1))
					get_parent().add_child(new_RL)
				"Pistol":
					var new_pistol = pistol.instantiate()
					new_pistol.global_position = global_position + Vector2(0, -15)
					new_pistol.apply_force(throw_power * Vector2(sign(global_position.x - get_global_mouse_position().x), 1))
					get_parent().add_child(new_pistol)
			item.queue_free()
			GlobalVars.slots[GlobalVars.current_slot_num] = null
			$Camera2D.position_smoothing_speed = 2
			SlotsHUD.update()
	if Input.is_action_pressed("zoom_in"):
		$Camera2D.zoom.x = min($Camera2D.zoom.x + 0.3 * delta, 1.0)
		$Camera2D.zoom.y = min($Camera2D.zoom.y + 0.3 * delta, 1.0)
	elif Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom.x = max($Camera2D.zoom.x - 0.3 * delta, 0.4)
		$Camera2D.zoom.y = max($Camera2D.zoom.y - 0.3 * delta, 0.4)
	
	if Input.is_action_just_pressed("respawn"):
		respawn()

func respawn():
	for body in get_parent().get_children():
		if "Bullet" in body.name or "Rocket" in body.name or "Enemy" in body.name or "Bullet" in body.name:
			body.free()
	is_slamming = false
	is_sliding = false
	velocity = Vector2(0, 0)
	global_position = Vector2(150, 156)
	$Camera2D.global_position = global_position
	$Camera2D.reset_smoothing()
	$AnimationPlayer.play("RESET")
	GlobalVars.player_hp = 100
func show_damage():
	#$blood.emitting = true
	pass

func animation_finished(anim_name: StringName) -> void:
	if anim_name == "slam_start" and is_on_floor():
		$AnimationPlayer.play("slam_stop")
func _on_slide_coyote_timeout() -> void:
	is_sliding = false
