extends Sprite2D

@onready var Tip: Sprite2D = $tip
@onready var Table: Node2D = $"../UI/HUD/Table"
@onready var Paper_button: TextureButton = $"../UI/HUD/Table/paper_button"
@onready var Anim: AnimationPlayer = $"../UI/HUD/Table/animations"

func _ready() -> void:
	Table.hide()
	$"../UI/HUD/AnimationPlayer".play_backwards("show_table")

func _process(delta: float) -> void:
	get_input()

func get_input():
	if Tip.visible and Input.is_action_just_pressed("rmb"):
		$"../UI/HUD/AnimationPlayer".play("show_table")
		Table.show()
		GlobalVars.player.SPEED_buffer = GlobalVars.player.SPEED
		GlobalVars.player.SPEED = 0
		GlobalVars.player.JUMP_VELOCITY_buffer = GlobalVars.player.JUMP_VELOCITY
		GlobalVars.player.JUMP_VELOCITY = 0
	if Table.visible and Input.is_action_just_pressed("esc"):
		Table.hide()
		GlobalVars.player.JUMP_VELOCITY = GlobalVars.player.JUMP_VELOCITY_buffer
		GlobalVars.player.SPEED = GlobalVars.player.SPEED_buffer

func reroll():
	pass
func _on_activation_range_body_entered(body: Node2D) -> void:
	if body == GlobalVars.player:
		$tip.show()
func _on_activation_range_body_exited(body: Node2D) -> void:
	if body == GlobalVars.player:
		$tip.hide()


func _on_paper_button_pressed() -> void:
	print(Anim.current_animation)
	if Anim.current_animation != "paper_show":
		Anim.play("paper_show")
