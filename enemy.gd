extends CharacterBody2D

@onready var player = GlobalVars.player
const SPEED = 350.0
const JUMP_VELOCITY = -400.0
var direction = Vector2(0, 0)
var hp = 100
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if global_position.y - player.global_position.y > 50 and is_on_floor() and global_position.distance_to(player.global_position) < 100:
		velocity.y = JUMP_VELOCITY

	direction = global_position.direction_to(player.global_position)
	if direction and global_position.distance_to(player.global_position) < 600 and abs(velocity.x) < 300:
		velocity.x += direction.x * SPEED * delta
		if sign(velocity.x) != sign(global_position.direction_to(player.global_position).x):
			velocity.x += velocity.x * -0.05
			print("ASD")
	else:
		velocity.x *= 0.9
	if hp <= 0:
		queue_free()
	move_and_slide()

func push(pwr, dir):
	velocity += pwr * dir
	hp -= 15
