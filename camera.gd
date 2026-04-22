extends Camera2D

var is_following : bool = false
var is_shaking : bool = false
var shake_power : float = 0.0

func _ready() -> void:
	is_following = true

func _process(delta: float) -> void:
	if is_shaking:
		global_position += Vector2(randi_range(shake_power * -1, shake_power), randi_range(shake_power * -1, shake_power))
	if is_following:
		global_position = lerp(GlobalVars.player.global_position, Vector2(delta, delta), Vector2(1, 1))
	if Input.is_action_just_released("zoom_in"):
		print("in")
		zoom.x = min(zoom.x + 1.5 * delta, 1.0)
		zoom.y = min(zoom.y + 1.5 * delta, 1.0)
	elif Input.is_action_just_released("zoom_out"):
		print("out")
		zoom.x = max(zoom.x - 1.5 * delta, 0.4)
		zoom.y = max(zoom.y - 1.5 * delta, 0.4)
func shake(time, power):
	is_shaking = true
	is_following = false
	shake_power = power
	position_smoothing_enabled = false
	await get_tree().create_timer(time).timeout
	position_smoothing_enabled = true
	is_following = true
	is_shaking = false
