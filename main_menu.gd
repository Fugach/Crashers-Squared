extends Node2D


@onready var text: RichTextLabel = $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"НАЧАТЬ".hide()
	$"НАСТРОЙКИ".hide()
	text.text = ""
	#text.default_color = Color(1.0, 0.635, 0.227, 1.0)
	await wait(0.5)
	text.text += "UNNAMED_OS_I_REALLY_DONT_KNOW(🄯)20XX UNNAMED COMPANY, Inc."
	await wait(0.1)
	text.text += "\n" + "\n" + "CPU: " + str(OS.get_processor_name())
	await wait(0.5)
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
	$"НАСТРОЙКИ".show()
	$"НАЧАТЬ".show()
	
 #...##...##.....##....#####
 #..###...##.#.#.##...#...##
 #.#.##...##..#..##.....#.##
 ##..##...##.....##...#...##

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func wait(x):
	await get_tree().create_timer(x).timeout

func _on_НАЧАТЬ_button_pressed() -> void:
	GlobalVars.lifes = 3
	get_tree().change_scene_to_file("res://main.tscn")
func _on_НАЧАТЬ_button_mouse_entered() -> void:
	$choose.play()
	$"НАЧАТЬ".text = ">> НАЧАТЬ <<"
func _on_НАЧАТЬ_button_mouse_exited() -> void:
	$"НАЧАТЬ".text = "НАЧАТЬ"

func _on_настройки_pressed() -> void:
	pass
func _on_настройки_mouse_entered() -> void:
	$choose.play()
	$"НАСТРОЙКИ".text = ">> НАСТРОЙКИ <<"
func _on_настройки_mouse_exited() -> void:
	$"НАСТРОЙКИ".text = "НАСТРОЙКИ"
