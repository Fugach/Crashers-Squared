extends Camera2D


var is_following : bool = false
var is_shaking : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_following = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_shaking:
		global_position += Vector2(randi_range(-5, 5), randi_range(-5, 5))
	if is_following:
		global_position = lerp(GlobalVars.player.global_position, Vector2(delta, delta), Vector2(1, 1))
func shake(time):
	is_shaking = true
	position_smoothing_enabled = false
	is_following = false
	await get_tree().create_timer(time).timeout
	is_shaking = false
	position_smoothing_enabled = true
	is_following = true
