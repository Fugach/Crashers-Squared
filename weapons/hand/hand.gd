extends Node2D

@onready var area_2d : Area2D = $Area2D
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
var targets = []

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("smash_hand") and not anim.is_playing():
		area_2d.monitoring = true
		#anim.scale.x = sign(global_position.x - get_global_mouse_position().x)
		anim.scale.x = -1
		var current_angle = (get_global_mouse_position() - global_position).normalized().angle()
		if -1.5 <= current_angle and current_angle <= 1.5:
			anim.scale.y = 1
		else:
			anim.scale.y = -1
		look_at(get_global_mouse_position())
		anim.play("smash_hand")


func _on_animated_sprite_2d_animation_finished() -> void:
	area_2d.monitoring = false
	targets = []


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body not in targets and body != GlobalVars.player:
		targets.append(body)
		if body.has_method("damage"):
			body.damage(10)
		if body.has_method("push"):
			body.push(550, (body.global_position - global_position).normalized())
