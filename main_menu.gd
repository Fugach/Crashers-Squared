extends Node2D

@onready var text: RichTextLabel = $RichTextLabel

func _ready() -> void:
	$start.hide()
	$settings.hide()
	text.text = ""
	#text.default_color = Color(1.0, 0.635, 0.227, 1.0)
	await wait(0.5)
	text.text += "UNNAMED_OS_I_REALLY_DONT_KNOW(🄯)20XX UNNAMED COMPANY, Inc."
	await wait(0.1)
	text.text += "\n" + "\n" + "CPU: " + str(OS.get_processor_name())
	await wait(0.5)
	main_menu()

func repeat(input, amount):
	for x in amount:
		text.text += input

func main_menu():
	text.text = ""
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.text = "-".repeat(100)
	await wait(0.2)
	text.text += "\n" + "##       # ##     ##  #           #  ##       #####"
	text.text += "\n" + "##     #   ##     ##    #   #     ##     #       ##"
	text.text += "\n" + "##   #     ##     ##      #       ##       ##  ##"
	text.text += "\n" + "## #       ##     ##             ##    #       ##"
	await wait(0.2)
	text.text += "\n" + "-".repeat(100)
	text.text += "\n\n\n\n\n\n\n\n\n" + "НАЧАТЬ"
	text.text += "\n\n\n" + "НАСТРОЙКИ"
	$settings.show()
	$start.show()
func settings():
	$settings.hide()
	$start.hide()
	text.text = ""
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	text.text += "\n\n\n\n\n\n"
	repeat(" ", 10)
	text.text += "Общая громкость\n"
	repeat(" ", 10)
	text.text += "Громкость музыки\n"
	repeat(" ", 10)
	text.text += "Громскость звуков\n"

func _process(delta: float) -> void:
	pass

func wait(x):
	await get_tree().create_timer(x).timeout

func _on_start_button_pressed() -> void:
	GlobalVars.lifes = 3
	get_tree().change_scene_to_file("res://main.tscn")
func _on_start_button_mouse_entered() -> void:
	$choose.play()
	$start.text = ">>                 <<"
func _on_start_button_mouse_exited() -> void:
	$start.text = ""

func _on_settings_pressed() -> void:
	settings()
func _on_settings_mouse_entered() -> void:
	$choose.play()
	$settings.text = ">>                          <<"
func _on_settings_mouse_exited() -> void:
	$settings.text = ""
