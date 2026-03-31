extends Node

var config = ConfigFile.new()
const CONFIG_FILE_PATH = "user://config.ini"


func _ready():
	if not FileAccess.file_exists(CONFIG_FILE_PATH):
		config.set_value("audio", "Master_volume_db", 0.0)
		config.set_value("audio", "Music_volume_db", -2.0)
		config.set_value("audio", "Sound_volume_db", 0.0)
		config.set_value("audio", "Atmosphere_volume_db", -5.0)
		config.save(CONFIG_FILE_PATH)
	else:
		config.load(CONFIG_FILE_PATH)

func save_audio(global_volume, music_volume, sound_volume, atmosphere_volume):
	config.set_value("audio", "Master_volume_db", global_volume)
	config.set_value("audio", "Music_volume_db", music_volume)
	config.set_value("audio", "Sound_volume_db", sound_volume)
	config.set_value("audio", "Atmosphere_volume_db", atmosphere_volume)
	config.save(CONFIG_FILE_PATH)
func get_value(section, key):
	return config.get_value(section, key)
