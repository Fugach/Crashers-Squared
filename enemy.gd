extends CharacterBody2D

const Shotgun = preload("uid://bsecy8dw60b21")
const RL = preload("uid://brcehntt6lxn6")
const Pistol = preload("uid://cdavqdqek4rr5")
const PARTS = preload("uid://o34nfwjqh6ot")


@onready var weapons = [Shotgun, RL, Pistol]
@onready var my_weapon : PackedScene = weapons.pick_random()
@onready var player = GlobalVars.player
var WEAPON : Node2D = null
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var direction = Vector2(0, 0)
var hp = 100
var total_damage : int = 0
var base_damage	 : int = 0
var parts_amount : int = 0

func _ready() -> void:
	var get_WEAPON = my_weapon.instantiate()
	get_WEAPON.weapon_owner = "Enemy"
	get_WEAPON.is_friendly = false
	add_child(get_WEAPON)
	WEAPON = get_WEAPON.get_child(1).get_parent()
	if my_weapon == Shotgun:
		base_damage = 3
	elif my_weapon == RL:
		base_damage = 10
	elif my_weapon == Pistol:
		base_damage = 8
func _physics_process(delta: float) -> void:
	if not is_on_floor() and hp > 0:
		velocity += get_gravity() * delta
	if player != null and hp > 0:
		#if WEAPON.is_player_nearby and WEAPON.can_shoot and GlobalVars.player_hp > 0:
			#WEAPON.shoot(base_damage, false)
		#if global_position.y - player.global_position.y > 50 and is_on_floor() and $shock.is_stopped() and global_position.distance_to(player.global_position) < 100:
			#velocity.y = JUMP_VELOCITY

		direction = global_position.direction_to(player.global_position)
		#if $shock.is_stopped():
			#if (global_position.distance_to(player.global_position) < 300 and\
			#global_position.distance_to(player.global_position) > 150) and abs(velocity.x) < 300:
				#velocity.x += direction.x * SPEED * delta
				#if sign(velocity.x) != sign(global_position.direction_to(player.global_position).x):
					#velocity.x += velocity.x * -0.05
			#elif global_position.distance_to(player.global_position) < 50:
				#velocity.x -= direction.x * SPEED * delta
		if hp > 0:
			velocity.x *= 0.9
	elif hp <= 0 and str(WEAPON) != "<Freed Object>":
		kill()
	move_and_slide()

func _process(delta: float) -> void:
	pass

func kill():
	GlobalVars.killed += 1
	$Sprite2D.self_modulate = Color(1, 1, 1, 0)
	$CollisionShape2D.disabled = true
	$Label.add_theme_color_override("font_color", Color(1.535, 0.325, 0.325, 6.5))
	WEAPON.queue_free()
	velocity = Vector2(0, 0)

func push(pwr, dir):
	velocity += pwr * dir
	$shock.start()

func damage(damage_amount):
	var new_part = PARTS.instantiate()
	new_part.power = damage_amount
	new_part.global_position = global_position
	new_part.heal = damage_amount * 0.25
	new_part.name = name + "_part" + str(parts_amount)
	parts_amount += 1
	new_part.direction = Vector2(-1, -1)
	get_parent().add_child(new_part)
	hp -= damage_amount
	total_damage += damage_amount
	$Label.text = str(total_damage)
	$damage.start()
	if $AnimationPlayer.current_animation != "show_damage":
		$AnimationPlayer.play("show_damage")



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "show_damage":
		$AnimationPlayer.play("hide")
	elif anim_name == "hide":
		$Label.text = ""
		total_damage = 0
