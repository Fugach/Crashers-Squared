extends Node2D
@onready var raycast : RayCast2D = $RayCast2D
@onready var line : Line2D = $Line2D
@onready var player = GlobalVars.player

func _ready() -> void:
	print("HAIII :3333")
	line.add_point(global_position)
	line.add_point(global_position + Vector2(1000, 0))
	await get_tree().create_timer(0.5).timeout
	print("BAIII :3333")
	queue_free()


func _process(delta: float) -> void:
	pass
