extends Node2D

@onready var camera : Camera2D = $Player/Camera2D
@onready var player : CharacterBody2D = $Player
@onready var CRT : ColorRect = $UI/Restart/CRT
@onready var CRT_mat: ShaderMaterial = CRT.material as ShaderMaterial
@onready var RestartUI : CanvasLayer = $UI/Restart
@onready var PauseUI : CanvasLayer = $UI/Pause
@onready var HUD : CanvasLayer = $UI/HUD
@onready var HPBar : TextureProgressBar = $UI/HUD/HPBar
@onready var HPLabel : Label = $UI/HUD/HPBar/HPLabel

@onready var HUDTable : Node2D = $UI/HUD/TABLE
@onready var TablePaperAnim : AnimationPlayer = $UI/HUD/TABLE/papers_anim
@onready var TableOtherAnim : AnimationPlayer = $UI/HUD/TABLE/other_anim

@onready var Vol_progress : TextureProgressBar = $UI/HUD/QuickVolume/progress
@onready var Vol_percent : ProgressBar = $UI/HUD/QuickVolume/percent
@onready var Vol_db : Label = $UI/HUD/QuickVolume/db
@onready var Vol_timer : Timer = $UI/HUD/QuickVolume/display_timer
@onready var Vol_anim : AnimationPlayer = $UI/HUD/QuickVolume/anim

var master_bus = AudioServer.get_bus_index("Master")
var last_papers_animation : String = ""
var last_other_anim : String = ""

func _ready() -> void:
	load_config()
	GlobalVars.main = self
	GlobalVars.player.respawn()
	TablePaperAnim.play("RESET")
	TableOtherAnim.play("RESET")
	HUDTable.hide()
	RestartUI.hide()
	$SubViewport.use_hdr_2d = true
	$UI/HUD/QuickVolume/AnimatedSprite2D.play("default")
	Vol_percent.value = round((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) + 25) / 50 * 100)
	if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) > 0:
		Vol_db.text = "|    +" + str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) + " дб"
	elif AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) < 0:
		Vol_db.text = "|    -" + str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) + " дб"
	else:
		Vol_db.text = "0 db"
	Vol_progress.value = Vol_percent.value
	

func load_config():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), GlobalConfig.get_value("audio", "Master_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), GlobalConfig.get_value("audio", "Music_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), GlobalConfig.get_value("audio", "Sound_volume_db"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Atmosphere"), GlobalConfig.get_value("audio", "Atmosphere_volume_db"))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("crash"):
		get_tree().quit(0)
	if Input.is_action_pressed("vol_up") and not Input.is_action_pressed("shift"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), min(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) + 1, 25))
		if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) <= -75:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -25)
		if $UI/HUD/QuickVolume.modulate == Color("ffffff00"):
			Vol_anim.play("show")
		elif Vol_anim.current_animation == "hide":
			Vol_anim.play_backwards("hide")
		update_volume()
	elif Input.is_action_pressed("vol_down") and not Input.is_action_pressed("shift"):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), max(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) - 1, -26))
		if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) == -26:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80.0)
		if $UI/HUD/QuickVolume.modulate == Color("ffffff00"):
			Vol_anim.play("show")
		elif Vol_anim.current_animation == "hide":
			Vol_anim.play_backwards("hide")
		update_volume()

func _process(delta: float) -> void:
	HUD.scale = $Player/Camera2D.scale
	HPLabel.text = str(GlobalVars.player_hp)
	HPBar.value = float(GlobalVars.player_hp)
	if $UI/HUD/TABLE/lmb_tip.self_modulate == Color("ffffffff") and Input.is_action_just_pressed("lmb"):
		TablePaperAnim.play_backwards("speed_up")
		GlobalVars.player.SPEED += 100
	if last_papers_animation == "pc_at_home" and Input.is_action_just_pressed("lmb"):
		TableOtherAnim.play("RESET")
	if Input.is_action_just_pressed("rmb") and $table/tip.visible:
		HUDTable.show()
	if Input.is_action_just_pressed("lmb") and TablePaperAnim.current_animation == "print" and\
	not $UI/HUD/TABLE/micro_pc_at_home.is_hovered():
		TablePaperAnim.play("speed_up")
	if ($table/tip.visible == false)\
	and HUDTable.visible:
		TableOtherAnim.play("RESET")
		HUDTable.hide()
		$table/mus.volume_db = 0.0
	if Input.is_action_just_pressed("shift"):
		$TileMapLayer.gen_dungeon(2)
		GlobalVars.player.respawn()
	if Input.is_action_just_pressed("esc"):
		get_tree().paused = true
		$UI/Pause/AnimationPlayer.play("appear")
		$UI/Pause.show()

func death():
	GlobalVars.player_hp = 0
	$UI/HUD/HPBar/HPLabel.text = str(GlobalVars.player_hp)
	$UI/HUD/HPBar.value =  GlobalVars.player_hp
	GlobalVars.apply_CRT(CRT_mat)
	$UI/Restart.death()
	get_tree().paused = true


func _on_button_pressed() -> void:
	if not TablePaperAnim.is_playing() and not TableOtherAnim.is_playing():
		TablePaperAnim.play("print")
		$UI/HUD/TABLE/print_noise.play()
		$UI/HUD/TABLE/table/Button.disabled = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	last_papers_animation = anim_name
	if anim_name == "print":
		$UI/HUD/TABLE/paper_sfx.play()
		if $UI/HUD/TABLE/pc_at_home.self_modulate.a == 1.0:
			TableOtherAnim.play_backwards("pc_at_home")
		TablePaperAnim.play("speed_up")

func _on_activation_range_body_entered(body: Node2D) -> void:
	if "Player" in str(body):
		$table/tip.show()
func _on_activation_range_body_exited(body: Node2D) -> void:
	if "Player" in str(body):
		$table/tip.hide()


func _on_micro_pc_at_home_pressed() -> void:
	if $UI/HUD/TABLE/pc_at_home.self_modulate == Color("ffffff00"):
		$UI/HUD/TABLE/paper_sfx.play()
		TableOtherAnim.play("pc_at_home")
	else:
		$UI/HUD/TABLE/paper_sfx.play()
		TableOtherAnim.play_backwards("pc_at_home")


func _on_other_anim_animation_finished(anim_name: StringName) -> void:
	last_other_anim = anim_name

func update_volume():
	$UI/HUD/QuickVolume/blip.pitch_scale = 1.0 + AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) * 0.01
	$UI/HUD/QuickVolume/blip.play()
	Vol_timer.start()
	Vol_percent.value = round((AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) + 25) / 50 * 100)
	if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) > 0:
		$UI/HUD/QuickVolume/infinity.hide()
		Vol_db.text = "|    +" + str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) + " дб"
	elif AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) == -80:
		$UI/HUD/QuickVolume/infinity.show()
		Vol_db.text = "|     -                дб"
	elif AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) < 0:
		$UI/HUD/QuickVolume/infinity.hide()
		Vol_db.text = "|    " + str(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))) + " дб"
	elif AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) == 0:
		$UI/HUD/QuickVolume/infinity.hide()
		Vol_db.text = "|         0.0 дб"
	Vol_progress.value = Vol_percent.value
	
	GlobalConfig.save_audio(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("music")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("sound")),\
	AudioServer.get_bus_volume_db(AudioServer.get_bus_index("atmosphere")))

func _on_display_timer_timeout() -> void:
	Vol_anim.play("hide")


func _on_stop_mus_pressed() -> void:
	$table/mus.autoplay = true
	$table/mus.play()


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


func _on_elevator_body_entered(body: Node2D) -> void:
	if body == player:
		$Elevator/tip.show()


func _on_elevator_body_exited(body: Node2D) -> void:
	if body == player:
		$Elevator/tip.hide()
