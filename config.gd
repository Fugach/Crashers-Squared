extends Node

var config = ConfigFile.new()
const CONFIG_FILE_PATH = "user://config.ini"


func _ready():
	if not FileAccess.file_exists(CONFIG_FILE_PATH):
		config.set_value("audio", "global_volume", 100.0)
		config.set_value("audio", "music_volume", 65.0)
		config.set_value("audio", "sound_volume", 100.0)
		config.set_value("audio", "atmosphere_volume", 80.0)
		config.save(CONFIG_FILE_PATH)
	else:
		config.load(CONFIG_FILE_PATH)

func save_audio(global_volume, music_volume, sound_volume, atmosphere_volume):
	config.set_value("audio", "global_volume", global_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sound_volume", sound_volume)
	config.set_value("audio", "atmosphere_volume", atmosphere_volume)
	config.save(CONFIG_FILE_PATH)
func get_value(section, key):
	return config.get_value(section, key)
