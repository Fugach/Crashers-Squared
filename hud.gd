extends CanvasLayer

@onready var Console : RichTextLabel = $Console
@onready var Anim : AnimationPlayer = $AnimationPlayer
@onready var Tiles : TileMapLayer = $"../../TileMapLayer"
@onready var TilesAnim : AnimationPlayer = $"../../TileMapLayer/AnimationPlayer"
@onready var Elevator : Area2D = $"../../Elevator"
@onready var Camera : Camera2D = $"../../Camera2D"

func _process(delta: float) -> void:
	pass
func wait(time):
	await get_tree().create_timer(time).timeout
func repeat(text, amount):
	for x in range(amount):
		Console.text += text
func results():
	Console.text = "                         -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                      РРРРРРР    ЕЕЕЕЕЕЕЕ   ЗЗЗЗЗЗ       УУ       УУ        ЛЛЛЛЛЛЛ       ЬЬ                 ТТТТТТТТТТ       АААААА      ТТТТТТТТТТ   ЫЫ                   ЫЫ          
                                       РР           Р  ЕЕ                         ЗЗ   УУ       УУ       ЛЛ        ЛЛ       ЬЬ                        ТТ            АА         АА           ТТ         ЫЫ                  ЫЫ      
                                        РРРРРРР    ЕЕЕЕЕЕЕ      ЗЗЗЗЗ          УУУУУУ        ЛЛ        ЛЛ      ЬЬЬЬЬЬЬ           ТТ            АААААААА          ТТ         ЫЫЫЫЫЫ      ЫЫ      
                                         РР               ЕЕ                         ЗЗ              УУ        ЛЛ        ЛЛ     ЬЬ         ЬЬ      ТТ            АА         АА         ТТ         ЫЫ         ЫЫ   ЫЫ           
                                           РР              ЕЕЕЕЕЕЕЕ   ЗЗЗЗЗЗ       УУУУУУ      ЛЛЛ         ЛЛ    ЬЬЬЬЬЬЬ        ТТ           АА         АА        ТТ         ЫЫЫЫЫЫ      ЫЫ          
                         ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
"
	Anim.play("hide_hud")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hide_hud":
		Console.text += "\n\n\n\n"
		repeat(" ", 125)
		Console.text += "ВРЕМЯ"
		await wait(0.5)
		repeat(" ", 35)
		Console.text += str(int(GlobalVars.time) / 60) + " : " + str(int(GlobalVars.time) % 60) + " : " + str(int(GlobalVars.time) % 1)
		await wait(1)
		for x in range(randi_range(45, 150)):
			Console.text += "РАБОТАЕМ НАД ЭТИМ "
			await wait(0.015)
			if randi_range(1, 6) == 6:
				Console.text += "\n"
		Console.clear()
		Camera.is_following = true
		await wait(1)
		await Tiles.gen_dungeon(randi_range(3, 15), Elevator.global_position / 16 + Vector2(-7, -7))
		TilesAnim.play("show")
		Anim.play("show_hud")
		Elevator.outside()


func _on_upgrade_1_mouse_entered() -> void:
	$Table/Upgrade1/choose.play()
func _on_upgrade_2_mouse_entered() -> void:
	$Table/Upgrade2/choose.play()
func _on_upgrade_3_mouse_entered() -> void:
	$Table/Upgrade3/choose.play()
