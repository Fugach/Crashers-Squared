extends CharacterBody2D

@onready var player = GlobalVars.player
@onready var shotgun: Sprite2D = $shotgun
@onready var rifle: Sprite2D = $rifle
@onready var pistol: Sprite2D = $pistol
@onready var shoot_timer : Timer = $shoot_timeout
const shot = preload("res://shot.tscn")
@onready var weapons = [shotgun, rifle, pistol]
@onready var WEAPON = weapons.pick_random()
const SPEED = 350.0
const JUMP_VELOCITY = -400.0
var can_shoot : bool = false
var direction = Vector2(0, 0)
var hp = 100
func _ready() -> void:
	print(WEAPON)
	WEAPON.show()

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
	else:
		velocity.x *= 0.9
	if hp <= 0:
		queue_free()
	move_and_slide()

func _process(delta: float) -> void:
	WEAPON.look_at(player.global_position)
	if -1.5 <= ((get_global_mouse_position() - WEAPON.global_position).normalized().angle()) and ((get_global_mouse_position() - WEAPON.global_position).normalized().angle()) <= 1.5:
		WEAPON.scale.y = -2
	else:
		WEAPON.scale.y = 2
	
	if can_shoot:
		var new_shot = shot.instantiate()
		new_shot.global_position = global_position
		new_shot.global_rotation = WEAPON.global_rotation
		get_parent().add_child(new_shot)
		can_shoot = false
		shoot_timer.start()
		

func push(pwr, dir):
	velocity += pwr * dir
	hp -= 15


func _on_shoot_timeout_timeout() -> void:
	can_shoot = true
