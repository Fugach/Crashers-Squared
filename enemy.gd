extends CharacterBody2D

const Shotgun = preload("uid://bsecy8dw60b21")
const RL = preload("uid://brcehntt6lxn6")

@onready var weapons = [Shotgun, RL]
@onready var my_weapon : PackedScene = weapons.pick_random()
@onready var player = GlobalVars.player
var WEAPON : Node2D = null
const SPEED = 350.0
const JUMP_VELOCITY = -400.0
var direction = Vector2(0, 0)
var hp = 100

func _ready() -> void:
	var get_WEAPON = my_weapon.instantiate()
	get_WEAPON.weapon_owner = "Enemy"
	get_WEAPON.is_friendly = false
	add_child(get_WEAPON)
	WEAPON = get_WEAPON.get_child(1).get_parent()
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player != null and hp > 0:
		if WEAPON.is_player_nearby and WEAPON.can_shoot and GlobalVars.player_hp > 0:
			WEAPON.shoot()
		if global_position.y - player.global_position.y > 50 and is_on_floor() and global_position.distance_to(player.global_position) < 100:
			velocity.y = JUMP_VELOCITY

		direction = global_position.direction_to(player.global_position)
		if (global_position.distance_to(player.global_position) < 300 and\
		global_position.distance_to(player.global_position) > 150) and abs(velocity.x) < 300:
			velocity.x += direction.x * SPEED * delta
			if sign(velocity.x) != sign(global_position.direction_to(player.global_position).x):
				velocity.x += velocity.x * -0.05
		elif global_position.distance_to(player.global_position) < 50:
			velocity.x -= direction.x * SPEED * delta
		elif hp > 0:
			velocity.x *= 0.9
	elif hp <= 0 and str(WEAPON) != "<Freed Object>":
		kill()
	move_and_slide()

func _process(delta: float) -> void:
	pass

func shoot(type):
	pass
func kill():
	GlobalVars.killed += 1
	$Sprite2D.self_modulate = Color(1, 1, 1, 0)
	$CollisionShape2D.disabled = true
	WEAPON.queue_free()
	velocity = Vector2(0, 0)
	$CPUParticles2D.show()
	$CPUParticles2D.emitting = true

func push(pwr, dir):
	velocity += pwr * dir

func damage(damage_amount):
	hp -= damage_amount

func _on_cpu_particles_2d_finished() -> void:
	queue_free()
