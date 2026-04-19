extends Node2D

@onready var CRT : ColorRect = $UI/Restart/CRT
@onready var CRT_mat: ShaderMaterial = CRT.material as ShaderMaterial
@onready var RestartUI : CanvasLayer = $UI/Restart
@onready var PauseUI : CanvasLayer = $UI/Pause
@onready var HUD : CanvasLayer = $UI/HUD
@onready var HPBar : TextureProgressBar = $UI/HUD/HPBar
@onready var HPLabel : Label = $UI/HUD/HPBar/HPLabel

@onready var Table: Node2D = $UI/HUD/Table

@onready var Camera: Camera2D = $Camera2D

func _ready() -> void:
	load_config()
	GlobalVars.main = self
	GlobalVars.player.respawn()
	$SubViewport.use_hdr_2d = true
	$UI/Pause/AnimationPlayer.play_backwards("appear")
	

func load_config():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), GlobalConfig.get_value("audio", "Master_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), GlobalConfig.get_value("audio", "Music_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), GlobalConfig.get_value("audio", "Sound_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Atmosphere"), GlobalConfig.get_value("audio", "Atmosphere_volume_db"))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("crash"):
		get_tree().quit(0)

func _process(delta: float) -> void:
	HUD.scale = Camera.scale
	HPLabel.text = str(GlobalVars.player_hp)
	HPBar.value = float(GlobalVars.player_hp)
	if GlobalVars.player.global_position.y > 500:
		$UI/HUD/QuickVolume/lost.play()
	if Input.is_action_just_pressed("mmb"):
		$TileMapLayer.gen_dungeon(1, Vector2(3, 2))
		GlobalVars.player.respawn()
		GlobalVars.time = 0.0
	if Input.is_action_just_pressed("esc") and not Table.visible:
		$UI/Pause.show()
		$UI/Pause/AnimationPlayer.play("appear")
		get_tree().paused = true

func death():
	GlobalVars.player_hp = 0
	$UI/HUD/HPBar/HPLabel.text = str(GlobalVars.player_hp)
	$UI/HUD/HPBar.value =  GlobalVars.player_hp
	GlobalVars.apply_CRT(CRT_mat)
	$UI/Restart.death()
	get_tree().paused = true


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_continue_pressed() -> void:
	$UI/Pause.hide()
	get_tree().paused = false


func _on_hp_bar_value_changed(value: float) -> void:
	if not HPBar.value > 0:
		HPBar.value = 0
		HPLabel.text = "0"
		GlobalVars.player_hp = 0
		death()

func _on_lost_finished() -> void:
	get_tree().quit(-1)


func _on_exit_mouse_entered() -> void:
	$UI/Pause/ColorRect/exit.text = ">> ВЫХОД <<"
func _on_exit_mouse_exited() -> void:
	$UI/Pause/ColorRect/exit.text = "ВЫХОД"


func _on_continue_mouse_entered() -> void:
	$UI/Pause/ColorRect/continue.text = ">> ПРОДОЛЖИТЬ <<"
func _on_continue_mouse_exited() -> void:
	$UI/Pause/ColorRect/continue.text = "ПРОДОЛЖИТЬ"
