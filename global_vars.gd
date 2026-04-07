extends Node

@onready var main : Node2D = null
@onready var player : CharacterBody2D = null
@onready var player_hp : int = 100
@onready var lifes : int = 3

var current_slot_num = "slot1"
var current_slot_node : Node2D = null
var slots : Dictionary[String, Node2D] = {
	"slot1": null,
	"slot2": null,
	"slot3": null
}
var player_velocity = Vector2(0, 0)
var player_pos = Vector2(0, 0)
var killed : int = 0
func damage(amount : int):
	if player_hp - amount > 0:
		player_hp -= amount
	else:
		player_hp = 0
		print("POW! YOU ARE DEAD!")
		main.death()
	player.show_damage()
