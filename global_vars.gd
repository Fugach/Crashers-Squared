extends Node

@onready var main : Node2D = null
@onready var player : CharacterBody2D = null
@onready var player_hp : int = 100
@onready var lifes : int = 3
@onready var spawn_pos : Vector2 = Vector2(0, 0)

var camera_positions = []
var current_slot_num = "slot1"
var current_slot_node : Node2D = null
var slots : Dictionary[String, Node2D] = {
	"slot1": null,
	"slot2": null,
	"slot3": null
}
var hand_slot : Node2D = null

var is_time_running : bool = false
var time : float = 0.0

var player_velocity = Vector2(0, 0)
var player_pos = Vector2(0, 0)
var killed : int = 0

func _process(delta: float) -> void:
	if is_time_running:
		time += delta

func damage(amount : int):
	if player_hp - amount > 0:
		player_hp -= amount
	else:
		player_hp = 0
		print("POW! YOU ARE DEAD!")
		main.death()
	player.show_damage()

func apply_CRT(body_material):
	if str(RenderingServer.get_current_rendering_method()) == "gl_compatibility":
		body_material.shader = preload("res://shaders/crt_OpenGL.gdshader")
		body_material.set_shader_parameter("brightness", 0.8)
		body_material.set_shader_parameter("contrast", 1.095)
		body_material.set_shader_parameter("saturation", 1.0)
		body_material.set_shader_parameter("gamma", 1.6)
		body_material.set_shader_parameter("curvature", 0.079)
		body_material.set_shader_parameter("vignette", 0.4)
		body_material.set_shader_parameter("scanline_strength", 0.634)
		body_material.set_shader_parameter("chroma_offset_px", 3.0)
		body_material.set_shader_parameter("jitter_px", 0.4)
		body_material.set_shader_parameter("wobble_px", 0.0)
		body_material.set_shader_parameter("tape_noise", 0.0)
		body_material.set_shader_parameter("tape_lines", 0.0)
		body_material.set_shader_parameter("roll_speed", 0.3)
		body_material.set_shader_parameter("roll_strength", 0.22)
		body_material.set_shader_parameter("glow_strength", 1.5)
		body_material.set_shader_parameter("glow_threshold", 0.05)
	elif str(RenderingServer.get_current_rendering_method()) == "forward_plus":
		body_material.shader =  preload("res://shaders/crt_Vulkan.gdshader")
		body_material.set_shader_parameter("resolution", Vector2(1280, 720))
		body_material.set_shader_parameter("warp_amount", 0.257)
		body_material.set_shader_parameter("noise_amount", 0.02)
		body_material.set_shader_parameter("vignette_amount", 1.0)
