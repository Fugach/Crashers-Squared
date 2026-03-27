extends Node2D

@onready var text: RichTextLabel = $RichTextLabel

func _ready() -> void:
	load_config()
	$settings_things.hide()
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
func wait(x):
	await get_tree().create_timer(x).timeout

func main_menu():
	$settings_things.hide()
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
	await wait(0.2)
	$settings_things.show()
	text.text += "\n\n"
	repeat(" ", 134)
	text.text += "СОХРАНИТЬ\n\n\n\n"
	repeat(" ", 10)
	text.text += "Общая громкость\n"
	repeat(" ", 10)
	text.text += "Громкость музыки\n"
	repeat(" ", 10)
	text.text += "Громкость звуков\n"
	repeat(" ", 10)
	text.text += "Громкость эффектов\n"

func _process(delta: float) -> void:
	pass

func load_config():
	$settings_things/global_volume.value = GlobalConfig.get_value("audio", "global_volume")
	$settings_things/mus_volume.value = GlobalConfig.get_value("audio", "music_volume")
	$settings_things/snd_volume.value = GlobalConfig.get_value("audio", "sound_volume")
	$settings_things/atm_volume.value = GlobalConfig.get_value("audio", "atmosphere_volume")

func _on_start_button_pressed() -> void:
	GlobalVars.lifes = 3
	get_tree().change_scene_to_file("res://main.tscn")
func _on_start_button_mouse_entered() -> void:
	$choose.play()
	$start.text = ">>                 <<"
func _on_start_button_mouse_exited() -> void:
	$start.text = ""

func _on_settings_pressed() -> void:
	$settings_things/global_volume.value = GlobalConfig.get_value("audio", "global_volume")
	$settings_things/mus_volume.value = GlobalConfig.get_value("audio", "music_volume")
	$settings_things/snd_volume.value = GlobalConfig.get_value("audio", "sound_volume")
	$settings_things/atm_volume.value = GlobalConfig.get_value("audio", "atmosphere_volume")
	settings()
func _on_settings_mouse_entered() -> void:
	$choose.play()
	$settings.text = ">>                          <<"
func _on_settings_mouse_exited() -> void:
	$settings.text = ""

func _on_settings_back_pressed() -> void:
	GlobalConfig.save_audio($settings_things/global_volume.value, $settings_things/mus_volume.value,\
	$settings_things/snd_volume.value, $settings_things/atm_volume.value)
	main_menu()
func _on_settings_back_mouse_entered() -> void:
	$settings_things/back.text = ">>                        <<"
func _on_settings_back_mouse_exited() -> void:
	$settings_things/back.text = ""

func _on_global_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value) - 30)
func _on_mus_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear_to_db(value) - 30)
func _on_snd_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sound"), linear_to_db(value) - 30)
func _on_atm_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("atmosphere"), linear_to_db(value) - 30)
