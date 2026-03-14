extends Node2D

@onready var camera : Camera2D = $Player/Camera2D
@onready var player : CharacterBody2D = $Player
var last_papers_animation : String = ""
var last_other_anim : String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVars.player_hp = 100
	GlobalVars.main = self
	$Player.respawn()
	$HUD/TABLE/papers_anim.play("RESET")
	$HUD/TABLE/other_anim.play("RESET")
	$HUD/TABLE.hide()
	$Restart.hide()
	$SubViewport.use_hdr_2d = true

func _process(delta: float) -> void:
	$HUD.scale = $Player/Camera2D.scale
	$HUD/HPBar.value = GlobalVars.player_hp
	$HUD/HPBar/Label.text = str(GlobalVars.player_hp)
	if $HUD/TABLE/lmb_tip.self_modulate == Color("ffffffff") and Input.is_action_just_pressed("lmb"):
		$HUD/TABLE/papers_anim.play_backwards("speed_up")
		$Player.SPEED += 100
	if last_papers_animation == "pc_at_home" and Input.is_action_just_pressed("lmb"):
		$HUD/TABLE/other_anim.play("RESET")
	if Input.is_action_just_pressed("rmb") and $table/tip.visible:
		$HUD/TABLE.show()
	if Input.is_action_just_pressed("lmb") and $HUD/TABLE/papers_anim.current_animation == "print":
		$HUD/TABLE/papers_anim.play("speed_up")
	if (Input.is_action_just_pressed("esc") or $table/tip.visible == false)\
	and $HUD/TABLE.visible:
		$HUD/TABLE.hide()

func death():
	if GlobalVars.lifes != 0:
		if GlobalVars.lifes > 1:
			$"Restart/ColorRect/tries".text = "У тебя есть ещё " + str(GlobalVars.lifes) + " шанса на победу"
		else:
			$"Restart/ColorRect/tries".text = "Последний шанс. \n \n \n я верю в тебя."
	else:
		$"Restart/ColorRect/tries".text = "мне очень жаль"
		$"Restart/ColorRect/again".text = "Конец"
		$"Restart/ColorRect/no".text = "ВЫХОД"
		$"Restart/ColorRect/yes".hide()
	$Restart/ColorRect.modulate.a = 0
	$Restart/CRT.modulate.a = 0
	$Restart.show()
	$Restart/AnimationPlayer.play("appear")
	$Restart/noise.playing = true

func _on_no_pressed() -> void:
	await get_tree().create_timer(0.3).timeout 
	get_tree().change_scene_to_file("res://main_menu.tscn")
func _on_no_mouse_entered() -> void:
	$Restart/choose.play()
	if GlobalVars.lifes != 0:
		$"Restart/ColorRect/no".text = ">НЕТ<"
	else:
		$"Restart/ColorRect/no".text = ">ВЫХОД<"
func _on_no_mouse_exited() -> void:
	if GlobalVars.lifes != 0:
		$"Restart/ColorRect/no".text = "НЕТ"
	else:
		$"Restart/ColorRect/no".text = "ВЫХОД"


func _on_yes_pressed() -> void:
	player.respawn()
	$HUD/TABLE/papers_anim.play("RESET")
	$HUD/TABLE.hide()
	GlobalVars.lifes -= 1
	$Restart/ColorRect.modulate.a = 0
	$Restart/CRT.modulate.a = 0
	$Restart.hide()
	$Restart/AnimationPlayer.stop()
	$Restart/noise.playing = false
func _on_yes_mouse_entered() -> void:
	$Restart/choose.play()
	$"Restart/ColorRect/yes".text = ">ДА<"
func _on_yes_mouse_exited() -> void:
	$"Restart/ColorRect/yes".text = "ДА"


func _on_button_pressed() -> void:
	if not $HUD/TABLE/papers_anim.is_playing() and not $HUD/TABLE/other_anim.is_playing():
		$HUD/TABLE/papers_anim.play("print")
		$HUD/TABLE/print_noise.play()
		$HUD/TABLE/table/Button.disabled = true



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	last_papers_animation = anim_name
	if anim_name == "print":
		$HUD/TABLE/paper_sfx.play()
		$HUD/TABLE/papers_anim.play("speed_up")
	


func _on_activation_range_body_entered(body: Node2D) -> void:
	if "Player" in str(body):
		$table/tip.show()
func _on_activation_range_body_exited(body: Node2D) -> void:
	if "Player" in str(body):
		$table/tip.hide()


func _on_micro_pc_at_home_pressed() -> void:
	if $HUD/TABLE/pc_at_home.self_modulate == Color("ffffff00"):
		$HUD/TABLE/paper_sfx.play()
		$HUD/TABLE/other_anim.play("pc_at_home")
	else:
		$HUD/TABLE/paper_sfx.play()
		$HUD/TABLE/other_anim.play_backwards("pc_at_home")


func _on_other_anim_animation_finished(anim_name: StringName) -> void:
	last_other_anim = anim_name
