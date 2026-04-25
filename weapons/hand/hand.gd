extends Node2D

@onready var hand: Node2D = $hand
@onready var hand_anim : AnimatedSprite2D = $hand/Hand_anim
@onready var hammer_raycast1: RayCast2D = $hammer/Hammer_anim/Hammer_raycast
@onready var hammer_raycast2: RayCast2D = $hammer/Hammer_anim/Hammer_raycast/second_one

@onready var Camera: Camera2D = $"../../Camera2D"
@onready var hammer: Node2D = $hammer
@onready var hammer_anim: AnimatedSprite2D = $hammer/Hammer_anim

var last_slot_num = ""
var is_spinning : bool = false

func _ready() -> void:
	hammer.hide()
	hand.hide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("shift") and $hammer/attack_cooldown.time_left <= 0:
		attack()
	if not Input.is_action_pressed("shift") and is_spinning:
		hammer_raycast1.enabled = false
		hammer_raycast2.enabled = false
		$hammer/attack_cooldown.start()
		is_spinning = false
		GlobalVars.player.can_jump = true
		hammer.hide()
		hammer_anim.stop()
		$hammer/spin_sfx.stop()

func _process(_delta: float) -> void:
	if hammer_raycast1.enabled and $hammer/attack_cooldown.time_left <= 0:
		hammer_logic(hammer_raycast1.get_collider(), hammer_raycast1)
		if is_spinning and hammer_raycast2.enabled:
			hammer_logic(hammer_raycast2.get_collider(), hammer_raycast2)

func hammer_logic(body, raycast):
	if "Enemy" in str(body):
		#if Camera.is_following:
		Camera.shake(0.1, 3)
		body.damage(10)
		body.push(250, raycast.get_collision_normal() + Vector2(PI, 0).rotated(global_rotation))
		hammer_raycast1.enabled = false
		hammer_raycast2.enabled = false
		$hammer/damage_cooldown.start()
		$hammer/damage_sfx.pitch_scale = randf_range(0.7, 1.3)
		$hammer/damage_sfx.play()
	elif body is TileMapLayer:
		$hammer/wall_hit_sfx.pitch_scale = randf_range(0.7, 1.3)
		$hammer/wall_hit_sfx.play()
		GlobalVars.player.push(600, raycast.get_collision_normal())
		hammer_raycast1.enabled = false
		hammer_raycast2.enabled = false
		$hammer/damage_cooldown.start()
	elif body is RigidBody2D:
		if body.has_method("damage"):
			body.damage(10)
		body.apply_central_impulse(250 * raycast.get_collision_normal() + Vector2(PI, 0).rotated(global_rotation))
		hammer_raycast1.enabled = false
		hammer_raycast2.enabled = false
		$hammer/damage_cooldown.start()

func _on_hammer_anim_animation_finished() -> void:
	if not Input.is_action_pressed("shift"):
		hammer_raycast1.enabled = false
		$hammer/attack_cooldown.start()
		hammer.hide()
	else:
		global_rotation = 0.0
		hammer_anim.play("loop")
		is_spinning = true
		$hammer/spin_sfx.play()
		hammer_raycast2.enabled = true

func attack():
	GlobalVars.player.can_jump = false
	look_at(get_global_mouse_position())
	hammer_raycast1.enabled = true
	hammer_anim.play("hit")
	hammer.show()
	$hammer/attack_sfx.play()

func _on_damage_cooldown_timeout() -> void:
	if is_spinning:
		hammer_raycast1.enabled = true
		hammer_raycast2.enabled = true
