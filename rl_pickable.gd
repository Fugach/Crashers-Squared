extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if visible and "Player" in str(body):
		if GlobalVars.items.item1 == "nothing":
			GlobalVars.items.item1 = "RL"
			$AudioStreamPlayer2D.play()
			visible = false
		elif GlobalVars.items.item2 == "nothing":
			GlobalVars.items.item2 = "RL"
			$AudioStreamPlayer2D.play()
			visible = false
		elif GlobalVars.items.item3 == "nothing":
			GlobalVars.items.item3 = "RL"
			$AudioStreamPlayer2D.play()
			visible = false

func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
