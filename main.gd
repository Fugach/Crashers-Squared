extends Node2D

@onready var camera : Camera2D = $Player/Camera2D
@onready var player : CharacterBody2D = $Player
@onready var CRT : ColorRect = $UI/Restart/CRT
@onready var CRT_mat: ShaderMaterial = CRT.material as ShaderMaterial

var master_bus = AudioServer.get_bus_index("Master")
var last_papers_animation : String = ""
var last_other_anim : String = ""
var is_paused : bool = false

func _ready() -> void:
	load_config()
	GlobalVars.player_hp = 100
	GlobalVars.main = self
	$Player.respawn()
	$UI/HUD/TABLE/papers_anim.play("RESET")
	$UI/HUD/TABLE/other_anim.play("RESET")
	$UI/HUD/TABLE.hide()
	$UI/Restart.hide()
	$SubViewport.use_hdr_2d = true

func load_config():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(GlobalConfig.get_value("audio", "global_volume")) - 30)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear_to_db(GlobalConfig.get_value("audio", "music_volume")) - 30)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound"), linear_to_db(GlobalConfig.get_value("audio", "sound_volume")) - 30)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("atmosphere"), linear_to_db(GlobalConfig.get_value("audio", "atmosphere_volume")) - 30)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("crash"):
		get_tree().quit(0)
	#if Input.is_action_just_pressed("vol_up"):
		#AudioServer.set_bus_volume_linear(master_bus, AudioServer.get_bus_volume_linear(master_bus) + 10)
		#print(AudioServer.get_bus_volume_linear(master_bus))
	#elif Input.is_action_just_pressed("vol_down"):
		#AudioServer.set_bus_volume_linear(master_bus, AudioServer.get_bus_volume_linear(master_bus) - 10)
		#AudioServer.get_bus_volume_linear(master_bus)
		#linear_to_db()
func _process(delta: float) -> void:
	$UI/HUD.scale = $Player/Camera2D.scale
	$UI/HUD/HPBar/Label.text = str(GlobalVars.player_hp)
	$UI/HUD/HPBar.value = float(GlobalVars.player_hp)
	if $UI/HUD/TABLE/lmb_tip.self_modulate == Color("ffffffff") and Input.is_action_just_pressed("lmb"):
		$UI/HUD/TABLE/papers_anim.play_backwards("speed_up")
		$Player.SPEED += 100
	if last_papers_animation == "pc_at_home" and Input.is_action_just_pressed("lmb"):
		$UI/HUD/TABLE/other_anim.play("RESET")
	if Input.is_action_just_pressed("rmb") and $table/tip.visible:
		$UI/HUD/TABLE.show()
		if not is_paused:
			$table/mus.volume_db = 5.0
	if Input.is_action_just_pressed("lmb") and $UI/HUD/TABLE/papers_anim.current_animation == "print" and\
	not $UI/HUD/TABLE/micro_pc_at_home.is_hovered():
		$UI/HUD/TABLE/papers_anim.play("speed_up")
	if ($table/tip.visible == false)\
	and $UI/HUD/TABLE.visible:
		$UI/HUD/TABLE/other_anim.play("RESET")
		$UI/HUD/TABLE.hide()
		$table/mus.volume_db = 0.0
	if Input.is_action_just_pressed("esc"):
		pause()
	if Input.is_action_just_pressed("shift"):
		$TileMapLayer.gen_dungeon(1)
		$Player.respawn()

func death():
	if str(RenderingServer.get_current_rendering_method()) == "gl_compatibility":
		CRT_mat.shader = preload("res://shaders/crt_OpenGL.gdshader")
		CRT_mat.set_shader_parameter("brightness", 0.8)
		CRT_mat.set_shader_parameter("contrast", 1.095)
		CRT_mat.set_shader_parameter("saturation", 1.0)
		CRT_mat.set_shader_parameter("gamma", 1.6)
		CRT_mat.set_shader_parameter("curvature", 0.079)
		CRT_mat.set_shader_parameter("vignette", 0.4)
		CRT_mat.set_shader_parameter("scanline_strength", 0.634)
		CRT_mat.set_shader_parameter("chroma_offset_px", 3.0)
		CRT_mat.set_shader_parameter("jitter_px", 0.4)
		CRT_mat.set_shader_parameter("wobble_px", 0.0)
		CRT_mat.set_shader_parameter("tape_noise", 0.0)
		CRT_mat.set_shader_parameter("tape_lines", 0.0)
		CRT_mat.set_shader_parameter("roll_speed", 0.3)
		CRT_mat.set_shader_parameter("roll_strength", 0.22)
		CRT_mat.set_shader_parameter("glow_strength", 1.5)
		CRT_mat.set_shader_parameter("glow_threshold", 0.05)
	elif str(RenderingServer.get_current_rendering_method()) == "forward_plus":
		CRT_mat.shader =  preload("res://shaders/crt_Vulkan.gdshader")
		CRT_mat.set_shader_parameter("resolution", Vector2(1280, 720))
		CRT_mat.set_shader_parameter("warp_amount", 0.257)
		CRT_mat.set_shader_parameter("noise_amount", 0.02)
		CRT_mat.set_shader_parameter("vignette_amount", 1.0)
	if GlobalVars.lifes != 0:
		if GlobalVars.lifes > 1:
			$"UI/Restart/ColorRect/tries".text = "У тебя есть ещё " + str(GlobalVars.lifes) + " шанса на победу"
		else:
			$"UI/Restart/ColorRect/tries".text = "Последний шанс. \n \n \n я верю в тебя."
	else:
		$"UI/Restart/ColorRect/tries".text = "мне очень жаль"
		$"UI/Restart/ColorRect/again".text = "Конец"
		$"UI/Restart/ColorRect/no".text = "ВЫХОД"
		$"UI/Restart/ColorRect/yes".hide()
	$UI/Restart/ColorRect.modulate.a = 0
	CRT.modulate.a = 0
	$UI/Restart.show()
	$UI/Restart/AnimationPlayer.play("appear")
	$UI/Restart/noise.playing = true

func _on_no_pressed() -> void:
	await get_tree().create_timer(0.3).timeout 
	get_tree().change_scene_to_file("res://main_menu.tscn")
func _on_no_mouse_entered() -> void:
	$UI/Restart/choose.play()
	if GlobalVars.lifes != 0:
		$"UI/Restart/ColorRect/no".text = ">НЕТ<"
	else:
		$"UI/Restart/ColorRect/no".text = ">ВЫХОД<"
func _on_no_mouse_exited() -> void:
	if GlobalVars.lifes != 0:
		$"UI/Restart/ColorRect/no".text = "НЕТ"
	else:
		$"UI/Restart/ColorRect/no".text = "ВЫХОД"


func _on_yes_pressed() -> void:
	player.respawn()
	$UI/HUD/TABLE/papers_anim.play("RESET")
	$UI/HUD/TABLE.hide()
	GlobalVars.lifes -= 1
	$UI/Restart/ColorRect.modulate.a = 0
	$UI/Restart/CRT.modulate.a = 0
	$UI/Restart.hide()
	$UI/Restart/AnimationPlayer.stop()
	$UI/Restart/noise.playing = false
func _on_yes_mouse_entered() -> void:
	$UI/Restart/choose.play()
	$"UI/Restart/ColorRect/yes".text = ">ДА<"
func _on_yes_mouse_exited() -> void:
	$"UI/Restart/ColorRect/yes".text = "ДА"


func _on_button_pressed() -> void:
	if not $UI/HUD/TABLE/papers_anim.is_playing() and not $UI/HUD/TABLE/other_anim.is_playing():
		$UI/HUD/TABLE/papers_anim.play("print")
		$UI/HUD/TABLE/print_noise.play()
		$UI/HUD/TABLE/table/Button.disabled = true



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	last_papers_animation = anim_name
	if anim_name == "print":
		$UI/HUD/TABLE/paper_sfx.play()
		if $UI/HUD/TABLE/pc_at_home.self_modulate.a == 1.0:
			$UI/HUD/TABLE/other_anim.play_backwards("pc_at_home")
		$UI/HUD/TABLE/papers_anim.play("speed_up")
	


func _on_activation_range_body_entered(body: Node2D) -> void:
	if "Player" in str(body):
		$table/tip.show()
func _on_activation_range_body_exited(body: Node2D) -> void:
	if "Player" in str(body):
		$table/tip.hide()


func _on_micro_pc_at_home_pressed() -> void:
	if $UI/HUD/TABLE/pc_at_home.self_modulate == Color("ffffff00"):
		$UI/HUD/TABLE/paper_sfx.play()
		$UI/HUD/TABLE/other_anim.play("pc_at_home")
	else:
		$UI/HUD/TABLE/paper_sfx.play()
		$UI/HUD/TABLE/other_anim.play_backwards("pc_at_home")


func _on_other_anim_animation_finished(anim_name: StringName) -> void:
	last_other_anim = anim_name
func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		$UI/Pause.show()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		$UI/Pause.hide()

func pause():
	if is_paused:
		is_paused = false
		$table/mus.volume_db = 0
		$table/mus_muff.volume_db = -80.0
		$UI/Pause.hide()
	elif not is_paused:
		is_paused = true
		$table/mus.volume_db = -80.0
		$table/mus_muff.volume_db = 0.0
		$UI/Pause.show()


func _on_finish_body_entered(body: Node2D) -> void:
	if body == player:
		for x in range(42):
			print("GOOD")
		$TileMapLayer.clear()
		$TileMapLayer/bg.clear()
		$TileMapLayer.gen_dungeon(randi_range(4, 16))
		player.respawn()
