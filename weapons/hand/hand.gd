extends Node2D

@onready var hammer_raycast1: RayCast2D = $Hammer_anim/Hammer_raycast
@onready var hammer_raycast2: RayCast2D = $Hammer_anim/Hammer_raycast/second_one

@onready var Camera: Camera2D = $"../../Camera2D"
@onready var hammer_anim: AnimatedSprite2D = $Hammer_anim

var last_slot_num = ""
var is_spinning : bool = false

func _ready() -> void:
	hammer_raycast1.enabled = false
	hammer_raycast2.enabled = false
	hide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shift") and $attack_cooldown.time_left <= 0:
		attack()
	if not Input.is_action_pressed("shift") and is_spinning:
		hammer_raycast1.enabled = false
		hammer_raycast2.enabled = false
		$attack_cooldown.start()
		is_spinning = false
		GlobalVars.player.can_jump = true
		hide()
		hammer_anim.stop()
		$spin_sfx.stop()

func _process(_delta: float) -> void:
	if hammer_anim.frame > 8:
		hammer_anim.z_index = -1
	else:
		hammer_anim.z_index = 0
	if hammer_raycast1.enabled and $attack_cooldown.time_left <= 0:
		hammer_logic(hammer_raycast1.get_collider(), hammer_raycast1)
		if is_spinning and hammer_raycast2.enabled:
			hammer_logic(hammer_raycast2.get_collider(), hammer_raycast2)

func hammer_logic(body, raycast):
	#if is_spinning:
		#if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			#rotation = PI / -12
		#if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			#rotation = PI / 12
		#if Input.is_action_pressed("move_right") == Input.is_action_pressed("move_left"):
			#rotation = 0
	if "Enemy" in str(body):
		Camera.shake(0.1, 3)
		body.damage(10, "hammer")
		body.push(250, raycast.get_collision_normal() + Vector2(PI, 0).rotated(global_rotation))
		hammer_raycast1.enabled = false
		hammer_raycast2.enabled = false
		$damage_cooldown.start()
		$damage_sfx.pitch_scale = randf_range(0.7, 1.3)
		$damage_sfx.play()
	elif body is TileMapLayer:
		$wall_hit_sfx.pitch_scale = randf_range(0.7, 1.3)
		$wall_hit_sfx.play()
		GlobalVars.player.push(400, raycast.get_collision_normal())
		hammer_raycast1.enabled = false
		hammer_raycast2.enabled = false
		$damage_cooldown.start()
	elif body is RigidBody2D:
		if body.has_method("damage"):
			body.damage(10, "hammer")
		body.apply_central_impulse(250 * raycast.get_collision_normal() + Vector2(PI, 0).rotated(global_rotation))
		hammer_raycast1.enabled = false
		hammer_raycast2.enabled = false
		$damage_cooldown.start()
	elif "Bullet" in str(body):
		body.Ricoshet.play()
		body.global_rotation += PI + randf_range(PI * -0.5, PI * 0.5)

func _on_hammer_anim_animation_finished() -> void:
	if not Input.is_action_pressed("shift"):
		GlobalVars.player.can_jump = true
		hammer_raycast1.enabled = false
		$attack_cooldown.start()
		hide()
	else:
		global_rotation = 0.0
		hammer_anim.play("loop")
		is_spinning = true
		$spin_sfx.play()
		hammer_raycast2.enabled = true

func attack():
	GlobalVars.player.can_jump = false
	look_at(get_global_mouse_position())
	hammer_raycast1.enabled = true
	hammer_anim.play("hit")
	show()
	$attack_sfx.play()

func _on_damage_cooldown_timeout() -> void:
	if is_spinning:
		hammer_raycast1.enabled = true
		hammer_raycast2.enabled = true
