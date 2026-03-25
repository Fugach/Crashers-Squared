extends RigidBody2D


@onready var player = get_node("/root/main/Player")

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func push(pwr, dir):
	linear_velocity += dir * pwr
