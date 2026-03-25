extends Sprite2D

@onready var RayCast: RayCast2D = $RayCast2D
@onready var Particles: CPUParticles2D = $CPUParticles2D
@onready var ExplosionPos: Sprite2D = $Babax
@onready var Collision: Area2D = $Babax/BabaxCollision

var can_push : bool = true
var speed = 100
var direction = 1
var is_emitting : bool = false
const SPEED: float = 500.0

func _ready():
	Collision.monitoring = false
	Particles.emitting = false
	ExplosionPos.visible = false
func _physics_process(delta: float):
	if not is_emitting:
		if RayCast.is_colliding() and str(RayCast.get_collider()).count("Player") == 0:
			destroy()
		else:
			global_position += Vector2(1, 0).rotated(rotation) * SPEED * delta

func destroy():
	self_modulate.a = 0
	Particles.global_position = RayCast.get_collision_point() + RayCast.get_collision_normal() * 5.0
	ExplosionPos.global_position = RayCast.get_collision_point() + RayCast.get_collision_normal() * 5.0
	Particles.amount = randi_range(5, 20)
	ExplosionPos.global_rotation = 0
	
	Collision.monitoring = true
	Particles.emitting = true
	is_emitting = true
	ExplosionPos.visible = true
	$Babax/AnimationPlayer.play("explostion_increasing")
	$Babax/AudioStreamPlayer2D.pitch_scale = randfn(1.0, 0.2)
	$Babax/AudioStreamPlayer2D.play()

func _on_distance_timeout():
	queue_free()

func _on_cpu_particles_2d_finished():
	queue_free()

func _on_collision_body_entered(body: Node2D):
	if ((body is CharacterBody2D) or (body is RigidBody2D)) and can_push:
		var explosion_pos = ExplosionPos.global_position
		var dir = (body.global_position - explosion_pos).normalized()
		var distance = explosion_pos.distance_to(body.global_position)
		var force = 800.0 / max(distance * 0.08, 1.0)
		body.push(force, dir)
func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explostion_increasing":
		can_push = false
		print(can_push)
