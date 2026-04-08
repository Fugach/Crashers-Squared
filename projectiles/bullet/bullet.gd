extends Node2D

@onready var Line : Line2D = $Line2D
@onready var Particles : GPUParticles2D = $GPUParticles2D
@onready var Collider : Area2D = $Area2D

var is_colliding : bool = false
var damage_amount : int = 0
var is_friendly : bool = false
var targets = []
var SPEED = 1000

func _ready() -> void:
	await get_tree().create_timer(60).timeout
	queue_free()

func _process(delta: float) -> void:
	if not is_colliding:
		#Line.set_point_position(0, Line.get_point_position(1) - Vector2(-3000 * delta, 0))
		position += Vector2(SPEED * delta, 0).rotated(global_rotation)

func wall_particles():
	Line.visible = false
	is_colliding = true
	Particles.emitting = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if "TileMapLayer" in str(body):
		wall_particles()
	elif "Player" in str(body) and body not in targets and not is_friendly:
		GlobalVars.damage(damage_amount)
		targets.append(body)
		queue_free()
	elif "Enemy" in str(body) and body not in targets:
		body.damage(damage_amount)
		targets.append(body)


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
