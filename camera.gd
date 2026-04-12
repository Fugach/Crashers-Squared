extends Camera2D


var is_following : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_following = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_following:
		global_position = GlobalVars.player.global_position
