extends Sprite2D

var light_scale : float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PointLight2D.texture_scale = light_scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
