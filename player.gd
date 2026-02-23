extends CharacterBody2D

const SPEED : float = 325.0
const ACCELERATION : float = 1000.0
const JUMP_VELOCITY : float = -500.0
var availible_jumps : int = 3
var boost_direction : int = 1
var boosts_available : float = 3.0
var is_boosting : bool = false
var velocity_buffer : Vector2 = velocity
var player_hp : int = 100
const push_power : float = 15.0
const box = preload("res://box.tscn")
const nailbreaker = preload("res://nailbreaker.tscn")
const RL = preload("res://rl_pickable.tscn")
const enemy = preload("res://enemy.tscn")

var is_sliding : bool = false
var is_slamming : bool = false
var is_hands_used : bool = false
var is_hand_grabbing : bool = false
var hand_touch : Node2D = null
@onready var steps: AudioStreamPlayer2D = $steps
@onready var wall_slide_loop: AudioStreamPlayer2D = $wall_slide_loop
@onready var wind: AudioStreamPlayer2D = $wind
@onready var hand : CharacterBody2D = $/root/main/hand
@onready var hand_collision : CollisionShape2D = $/root/main/hand/CollisionShape2D
@onready var hand_joint : PinJoint2D = $/root/main/hand/PinJoint2D

func _ready() -> void:
	GlobalVars.player = self
	hand.hide()
	hand_collision.disabled = true
	hand.add_collision_exception_with(self)

func _physics_process(delta: float) -> void:
	if is_on_wall_only() and (not is_on_floor()) and velocity.y > 0 and sign(get_wall_normal().x) == boost_direction * -1 and\
	(Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		is_sliding = true
		velocity.y += get_gravity().y * delta * 0.1 # скользим по стенам
	elif not is_on_floor():
		is_sliding = false
		velocity.y += get_gravity().y * delta # базовое падение
	else:
		is_sliding = false
	
	if is_sliding:
		wall_slide_loop.volume_db = 0.0
	else:
		wall_slide_loop.volume_db = -80.0
	if boosts_available < 3:
		boosts_available += 0.5 * delta
	
	var previous_velocity = velocity
	
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
	GlobalVars.player_velocity = velocity
	GlobalVars.player_pos = global_position
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
		var new_enemy = enemy.instantiate()
		new_enemy.global_position = get_global_mouse_position()
		get_parent().add_child(new_enemy)

func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
		if $AnimationPlayer.current_animation == "slam_stop":
			$AnimationPlayer.play("RESET")
	elif Input.is_action_just_pressed("jump") and is_on_wall_only() and availible_jumps > 0:
		if is_slamming:
			is_slamming = false
			$AnimationPlayer.stop()
		velocity.x = sign(get_wall_normal().x) * 300
		velocity.y = -500
		availible_jumps -= 1
	if is_on_floor():
		availible_jumps = 3

func fall():
	if position.y > 10000:
		position.y = 233
		position.x = 233
		velocity = Vector2(0, 0)
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
	if anim_name == "boost_start":
		if boost_direction > 0:
			$AnimationPlayer.play("boost_finish_right")
		else:
			$AnimationPlayer.play("boost_finish_left")

func push(pwr, _dir):
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		velocity += pwr * Vector2(-5.5, -1)
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		velocity += pwr * Vector2(5.5, -1)
	else:
		velocity += pwr * Vector2(0, -1)

func get_input(delta: float) -> void:
	hands()
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		boost_direction = -1
		if not is_boosting:
			velocity.x -= ACCELERATION * delta
			if not steps.is_playing() and is_on_floor() and velocity.x != 0:
				steps.play()
			if velocity.x < SPEED * -1:
				velocity.x = SPEED * -1
	if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		boost_direction = 1
		if not is_boosting:
			velocity.x += ACCELERATION * delta
			if not steps.is_playing() and is_on_floor() and velocity.x != 0:
				steps.play()
			if velocity.x > SPEED:
				velocity.x = SPEED
	if Input.is_action_just_pressed("slam") and not is_on_floor() and not Input.is_action_just_pressed("jump"):
		$AnimationPlayer.play("slam_start")
		velocity.y = 1500
		velocity.x = 0
		is_boosting = false
		is_slamming = true
	elif is_slamming and is_on_floor():
		$AnimationPlayer.play("slam_stop")
		is_slamming = false
	elif is_slamming and is_sliding:
		$AnimationPlayer.stop()
		is_slamming = false
	if int(Input.is_action_pressed("move_left")) == int(Input.is_action_pressed("move_right")) and\
	is_on_floor():
		velocity.x *= 0.95
	
	if Input.is_action_just_pressed("item1"):
		GlobalVars.current_item = GlobalVars.items.item1
	elif Input.is_action_just_pressed("item2"):
		GlobalVars.current_item = GlobalVars.items.item2
	elif Input.is_action_just_pressed("item3"):
		GlobalVars.current_item = GlobalVars.items.item3
	
	if Input.is_action_pressed("zoom_in"):
		$Camera2D.zoom.x = min($Camera2D.zoom.x + 0.3 * delta, 1.0)
		$Camera2D.zoom.y = min($Camera2D.zoom.y + 0.3 * delta, 1.0)
	elif Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom.x = max($Camera2D.zoom.x - 0.3 * delta, 0.4)
		$Camera2D.zoom.y = max($Camera2D.zoom.y - 0.3 * delta, 0.4)
	
	if Input.is_action_just_pressed("respawn"):
		is_slamming = false
		is_sliding = false
		velocity = Vector2(0, 0)
		global_position = Vector2(233, 233)
		$Camera2D.reset_smoothing()
		$Camera2D.global_position = Vector2(233, 233)
		$AnimationPlayer.play("RESET")

func hands():
	if Input.is_action_just_pressed("hands"):
		is_hands_used = true
		is_hand_grabbing = false
		hand.show()
		hand.global_position = global_position + Vector2(0, 5)
	if is_hands_used and is_hand_grabbing == false:
		hand.look_at(get_global_mouse_position())
		hand.velocity = lerp((hand.global_position - get_global_mouse_position()) * -2, get_global_mouse_position(), get_global_mouse_position())
	elif is_hand_grabbing:
		hand.velocity = Vector2(0, 0)
	if not Input.is_action_pressed("hands") and hand.is_visible() == true:
		is_hands_used = false
		is_hand_grabbing = false
		hand_joint.node_b = ""
		hand.look_at(global_position)
		hand.velocity = lerp((hand.global_position - global_position) * -5, global_position, global_position)
	if is_hands_used == false and hand.global_position.distance_to(global_position) < 20:
		hand.hide()
	
	if is_hands_used:
		hand_collision.disabled = false
	else:
		hand_collision.disabled = true
	if is_hand_grabbing and is_hands_used and is_on_floor():
		var boost_pwr = hand.global_position.direction_to(get_global_mouse_position()) * -1 * hand.global_position.distance_to(get_global_mouse_position())
		if abs(boost_pwr) <= Vector2(100, 100):
			velocity += boost_pwr
			is_hand_grabbing = false
	
	
	if ("RigidBody2D" in str(hand_touch)) and is_hands_used:
		hand_joint.node_a = hand.get_path()
		hand_joint.node_b = hand_touch.get_path()
	if not is_hands_used or not Input.is_action_pressed("use"):
		is_hand_grabbing = false
		hand_joint.node_b = ""
	
	hand.move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	hand_touch = body
func _on_area_2d_body_exited(body: Node2D) -> void:
	hand_touch = null
