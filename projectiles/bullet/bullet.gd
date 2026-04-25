extends Node2D

@onready var Line : Line2D = $Line2D
@onready var Particles : GPUParticles2D = $GPUParticles2D
@onready var Raycast : RayCast2D = $RayCast2D

var damage_amount : int = 0
var is_friendly : bool = false
var targets = []
var SPEED = 800

func _ready() -> void:
	await get_tree().create_timer(60).timeout
	queue_free()

func _process(delta: float) -> void:
	if Raycast.get_collider() != null:
		var body = Raycast.get_collider()
		if body not in targets:
			targets.append(body)
			if body == GlobalVars.player and not is_friendly:
				GlobalVars.damage(damage_amount)
				Raycast.enabled = false
				queue_free()
			elif "TileMapLayer" in str(body):
				wall_particles()
				Raycast.enabled = false
			elif "Enemy" in str(body):
				body.damage(damage_amount)
				body.push(75, Vector2(1, 0).rotated(global_rotation))
				Raycast.enabled = false
				queue_free()
			elif body is RigidBody2D:
				if body.has_method("damage"):
					body.damage(damage_amount)
				if body.has_method("push"):
					body.push(50, Vector2(1, 0).rotated(global_rotation))
				if body.penetrable == false:
					if randi_range(1, 4) > 1:
						Raycast.enabled = false
						queue_free()
					else:
						$Ricoshet.play()
						global_rotation += PI + randf_range(PI * -0.5, PI * 0.5)
	if Raycast.enabled:
		position += Vector2(SPEED * delta, 0).rotated(global_rotation)
	else:
		Line.set_point_position(0, global_position)
		Line.set_point_position(1, Raycast.get_collision_point())

func wall_particles():
	Line.visible = false
	Particles.global_position = Raycast.get_collision_point()
	Particles.emitting = true

#func _on_area_2d_body_entered(body: Node2D) -> void:
	#if "TileMapLayer" in str(body):
		#wall_particles()
		#Line.set_point_position(1, Collider.colli)
	#elif "Player" in str(body) and body not in targets and not is_friendly:
		#GlobalVars.damage(damage_amount)
		#targets.append(body)
		#Line.visible = false
		#queue_free()
	#elif "Enemy" in str(body) and body not in targets:
		#body.damage(damage_amount)
		#targets.append(body)
	#elif body is RigidBody2D:
		#targets.append(body)
		#if body.has_method("push"):
			#body.push(50, Vector2(1, 0).rotated(global_rotation))
		#if body.has_method("damage"):
			#body.damage(damage_amount)
			#queue_free()


func _on_gpu_particles_2d_finished() -> void:
	queue_free()
