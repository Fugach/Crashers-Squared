extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.frame = 0
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if ("Player" in str(body) or "RigidBody2D" in str(body) or "CharacterBody2D" in str(body)) and not $AnimatedSprite2D.is_playing():
		if global_position.x > body.global_position.x:
			scale.x = -1.0
		else:
			scale.x = 1.0
		$AnimatedSprite2D.speed_scale = 1.0 + (body.global_position.x / global_position.x)
		$AnimatedSprite2D.play("door_open")
		$open.play()


func _on_animation_finished() -> void:
	if $AnimatedSprite2D.get_frame() == 50 or not $AnimatedSprite2D.get_frame() == 43:
		$AnimatedSprite2D.play("door_close")
	else:
		$close.play()
