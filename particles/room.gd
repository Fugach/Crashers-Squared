extends Node2D

var activation_range : Vector2 = Vector2(0, 0)
var door1 : Node2D = null
var door2 : Node2D = null
var room_number : int = 0
var pending_enemies : int = 0
var total_enemies : int = 0
const ENEMY = preload("uid://x2aibfdis1lc")

@onready var Camera_pos: Marker2D = $Camera_pos
@onready var Camera: Camera2D = $"../../Camera2D"

func _ready() -> void:
	Camera_pos.global_position += activation_range / 2
	$Area2D.global_position += activation_range / 2
	$Darkness.size = activation_range + Vector2(32, 0)
	$Darkness.global_position.x -= 16
	$Area2D/CollisionShape2D.shape.size = activation_range - Vector2(32, 32)
	$Darkness.set_anchors_preset(Control.PRESET_CENTER)

func _process(delta: float) -> void:
	while pending_enemies > 0:
		var new_enemy = ENEMY.instantiate()
		new_enemy.name = "Enemy" + str(total_enemies)
		total_enemies += 1
		new_enemy.global_position += activation_range / 2
		$"..".add_child(new_enemy)
		pending_enemies -= 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		Camera.is_following = false
		Camera.global_position = Camera_pos.global_position
		$Darkness.hide()
		if GlobalVars.cleared_rooms.has(name) and GlobalVars.cleared_rooms[name] == false:
			if door1.Collision.disabled == true:
				door1.call_deferred("lock", "close")
			if door2.Collision.disabled == true:
				door2.call_deferred("lock", "close")
			pending_enemies = randi_range(1,  10)
