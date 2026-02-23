extends Sprite2D

@onready var Player: CharacterBody2D = $/root/main/Player
var timeout: float = 0.0
var is_hand_touching: bool = true
func _ready() -> void:
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_hand_touching:
		global_position += Vector2(1, 1).rotated(rotation) * delta * 500
		print("weeeee")
	else:
		global_position = lerp(get_global_mouse_position(), Player.global_position, 0)

func hand(delta):
	is_hand_touching = false
	look_at(get_global_mouse_position())
	global_position = Player.global_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if str(body).count("wall") > 0:
		is_hand_touching = true
		print("ouch!")
