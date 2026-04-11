extends Area2D

@onready var Tip: Sprite2D = $Outside/tip
@onready var Elevator: AnimatedSprite2D = $Outside/Elevator
@onready var Tile_map_layer : TileMapLayer = $"../TileMapLayer"
@onready var Tile_map_layer_bg : TileMapLayer = $"../TileMapLayer/bg"
@onready var Inside : StaticBody2D = $Inside
@onready var Outside: Node2D = $Outside

func _ready() -> void:
	$Inside.modulate.a = 0
func _on_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		Elevator.play("open")
		Tip.show()

func _on_body_exited(body: Node2D) -> void:
	if body == GlobalVars.player:
		Tip.hide()
		Elevator.play("close")

func _process(delta: float):
	if Input.is_action_just_pressed("rmb") and Tip.visible:
		GlobalVars.player.goto_elevator()
		Tip.hide()

func results():
	$AnimationPlayer.play("show_inside")
	$CollisionShape2D.disabled = false
	GlobalVars.player.velocity = Vector2(0, 0)
	
