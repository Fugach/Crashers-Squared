extends Node2D
@onready var raycast : RayCast2D = $RayCast2D
@onready var line : Line2D = $Line2D
var damage : int = 0
func _ready() -> void:
	raycast.force_raycast_update()
	await get_tree().create_timer(5).timeout
	queue_free()


func _process(delta: float) -> void:
	raycast.force_raycast_update()
	if raycast.is_colliding():
		if "TileMapLayer" in str(raycast.get_collider()):
			queue_free()
		if "Player" in str(raycast.get_collider()):
			GlobalVars.damage(damage)
			queue_free()
	position += Vector2(2500 * delta, 0).rotated(global_rotation)
