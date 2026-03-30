extends Node2D

@onready var raycast : RayCast2D = $RayCast2D
@onready var line : Line2D = $Line2D
@onready var Particles : CPUParticles2D = $CPUParticles2D
@onready var Particles_col : Area2D = $CPUParticles2D/Area2D


var is_colliding : bool = false
var damage_amount : int = 0
var is_friendly : bool = false
func _ready() -> void:
	raycast.force_raycast_update()
	await get_tree().create_timer(5).timeout
	queue_free()


func _process(delta: float) -> void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if "TileMapLayer" in str(raycast.get_collider()):
			wall_particles()
		if "Player" in str(raycast.get_collider()) and not is_friendly:
			GlobalVars.damage(damage_amount)
		if "Enemy"  in str(raycast.get_collider()):
			raycast.get_collider().damage(damage_amount)
	if not is_colliding:
		position += Vector2(1000 * delta, 0).rotated(global_rotation)

func wall_particles():
	line.visible = false
	raycast.visible = true
	is_colliding = true
	Particles.emitting = true

func _on_cpu_particles_2d_finished() -> void:
	queue_free()
