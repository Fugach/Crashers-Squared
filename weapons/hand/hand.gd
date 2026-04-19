extends Node2D

@onready var hand: Node2D = $hand
@onready var hand_area_2d : Area2D = $hand/hand_area2D
@onready var hand_anim : AnimatedSprite2D = $hand/Hand_anim
@onready var hammer_smash: AudioStreamPlayer2D = $hammer/smash

@onready var hammer: Node2D = $hammer
@onready var hammer_anim: AnimatedSprite2D = $hammer/Hammer_anim
@onready var hammer_area_2d: Area2D = $hammer/hammer_area2D

var targets = []

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("smash_hand") and not hand_anim.is_playing():
		hand_area_2d.monitoring = true
		hand_anim.scale.x = -1
		var current_angle = (get_global_mouse_position() - global_position).normalized().angle()
		if -1.5 <= current_angle and current_angle <= 1.5:
			hand_anim.scale.y = 1
		else:
			hand_anim.scale.y = -1
		look_at(get_global_mouse_position())
		hand_anim.play("smash_hand")
	if Input.is_action_just_pressed("shift") and not hammer_anim.is_playing() and $hammer/Timer.is_stopped():
		hammer.show()
		$hammer/Timer.start()
		look_at(get_global_mouse_position())
		#$hammer/hammer_area2D/CollisionShape2D.position.x = sign(global_position.x - get_global_mouse_position().x) * -14
		#hammer_anim.scale.x = sign(global_position.x - get_global_mouse_position().x) * -1
		hammer_anim.play("hit")
		hammer_smash.play()
		hammer_area_2d.monitoring = true


func _on_hand_area_2d_body_entered(body: Node2D) -> void:
	hand_area_2d.monitoring = false
	targets = []


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body not in targets and body != GlobalVars.player:
		targets.append(body)
		if body.has_method("damage"):
			body.damage(10)
			if body is RigidBody2D:
				body.apply_impulse(300 * Vector2.RIGHT.rotated(global_rotation))
		if body.has_method("push"):
			body.push(550, (body.global_position - global_position).normalized())


func _on_hammer_anim_animation_finished() -> void:
	hammer.hide()
	hammer_area_2d.monitoring = false
	targets = []


func _on_hammer_area_2d_body_entered(body: Node2D) -> void:
	if "Enemy" in str(body):
		body.damage(10)
		body.push(250, (body.global_position - global_position))
	elif body is TileMapLayer:
		hammer_area_2d.monitoring = false
		GlobalVars.player.push(600, global_position.normalized())
