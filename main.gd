extends Node2D

@onready var camera : Camera2D = $Camera2D
@onready var player : CharacterBody2D = $Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport.use_hdr_2d = true

func _process(delta: float) -> void:
	$CanvasLayer.scale = $Player/Camera2D.scale
	$CanvasLayer/HPBar.value = GlobalVars.player_hp
	$CanvasLayer/HPBar/Label.text = str(GlobalVars.player_hp)

func _on_нет_pressed() -> void:
	$"CanvasLayer2/Чёрный".show()
	await get_tree().create_timer(0.3).timeout 
	get_tree().change_scene_to_file("res://main_menu.tscn")
func _on_нет_mouse_entered() -> void:
	$"CanvasLayer2/НЕТ".text = ">НЕТ<"
func _on_нет_mouse_exited() -> void:
	$"CanvasLayer2/НЕТ".text = "НЕТ"
