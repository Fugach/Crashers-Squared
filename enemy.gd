extends CharacterBody2D

@onready var shotgun: Sprite2D = $shotgun
@onready var shotgun_col: ShapeCast2D = $shotgun/ShapeCast2D

@onready var rifle: Sprite2D = $rifle
@onready var rifle_col: RayCast2D = $rifle/RayCast2D

@onready var pistol: Sprite2D = $pistol
@onready var pistol_col: ShapeCast2D = $pistol/ShapeCast2D

@onready var shoot_timer : Timer = $shoot_timeout
const projectile_shot = preload("res://shot.tscn")

@onready var weapons = [shotgun, rifle, pistol]
@onready var WEAPON = weapons.pick_random()
@onready var player = GlobalVars.player

const SPEED = 350.0
const JUMP_VELOCITY = -400.0
var can_shoot : bool = false
var direction = Vector2(0, 0)
var hp = 100

func _ready() -> void:
	WEAPON.show()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if player != null:
		if hp > 0 and global_position.y - player.global_position.y > 50 and is_on_floor() and global_position.distance_to(player.global_position) < 100:
			velocity.y = JUMP_VELOCITY

		direction = global_position.direction_to(player.global_position)
		if hp > 0 and direction and (global_position.distance_to(player.global_position) < 300 and\
		global_position.distance_to(player.global_position) > 150) and abs(velocity.x) < 300:
			velocity.x += direction.x * SPEED * delta
			if sign(velocity.x) != sign(global_position.direction_to(player.global_position).x):
				velocity.x += velocity.x * -0.05
		elif global_position.distance_to(player.global_position) < 50:
			velocity.x -= direction.x * SPEED * delta
		elif hp > 0:
			velocity.x *= 0.9
		if hp <= 0:
			GlobalVars.killed += 1
			$Sprite2D.self_modulate = Color(1, 1, 1, 0)
			$CollisionShape2D.disabled = true
			WEAPON.hide()
			velocity = Vector2(0, 0)
			$CPUParticles2D.show()
			$CPUParticles2D.emitting = true
	move_and_slide()

func _process(delta: float) -> void:
	if global_position.distance_to(player.global_position) < 400:
		WEAPON.global_rotation = lerp_angle(WEAPON.global_rotation, (player.global_position - global_position).angle(), delta * 10)
	else:
		WEAPON.global_rotation = 0
	
	if -1.5 <= WEAPON.global_rotation and WEAPON.global_rotation <= 1.5:
		WEAPON.scale.y = -1
	else:
		WEAPON.scale.y = 1
	if can_shoot and hp > 0 and GlobalVars.player_hp != 0 and global_position.distance_to(player.global_position) < 400:
		match WEAPON:
			rifle:
				if ("Player" in str(rifle_col.get_collider()) or randi_range(0, 1)):
					shoot(WEAPON)
				print(rifle_col.get_collider())
			shotgun:
				if ("Player" in str(shotgun_col.collision_result)) or randi_range(0, 1):
					shoot(WEAPON)
				print(shotgun_col.collision_result)
			pistol:
				if ("Player" in str(pistol_col.collision_result)) or randi_range(0, 1):
					shoot(WEAPON)
				print(pistol_col.collision_result)
		can_shoot = false
		shoot_timer.start()

func shoot(type):
	print("POW! ", WEAPON)
	match type:
		pistol:
			var new_shot = projectile_shot.instantiate()
			new_shot.damage = 10
			new_shot.global_position = global_position
			new_shot.global_rotation = WEAPON.global_rotation
			
			WEAPON.global_rotation += randf_range(-0.15, -0.25)
			new_shot.global_position += Vector2(10, 0).rotated(WEAPON.global_rotation)
			get_parent().add_child(new_shot)
		rifle:
			var new_shot = projectile_shot.instantiate()
			new_shot.damage = 20
			new_shot.global_position = global_position
			new_shot.global_rotation = WEAPON.global_rotation
			
			WEAPON.global_rotation += randf_range(-0.0, -0.1) * sign(WEAPON.global_rotation)
			new_shot.global_position += Vector2(20, 0).rotated(WEAPON.global_rotation)
			get_parent().add_child(new_shot)
		shotgun:
			for x in range(5):
				var new_shot = projectile_shot.instantiate()
				new_shot.damage = 3
				new_shot.global_position = global_position
				new_shot.global_rotation = WEAPON.global_rotation
				
				new_shot.global_position += Vector2(20, 0).rotated(WEAPON.global_rotation)
				new_shot.global_rotation = WEAPON.global_rotation + randf_range(-0.2, 0.2)
				get_parent().add_child(new_shot)

func push(pwr, dir):
	velocity += pwr * dir
	hp -= 100
func _on_shoot_timeout_timeout() -> void:
	can_shoot = true
func _on_cpu_particles_2d_finished() -> void:
	queue_free()
