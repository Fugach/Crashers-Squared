extends Node

@onready var main : Node2D = null
@onready var player : CharacterBody2D = null
@onready var player_hp : int = 100
@onready var lifes : int = 3
var current_item = "nothing"
var current_slot = ""
var items = {
	"item1": "nothing",
	"item2": "nothing",
	"item3": "nothing"
}
var player_velocity = Vector2(0, 0)
var player_pos = Vector2(0, 0)
var killed : int = 0
func damage(amount : int):
	if player_hp - amount >= 0:
		player_hp -= amount
	else:
		player_hp = 0
	player.show_damage()
	if player_hp <= 0:
		print("POW! YOU ARE DEAD!")
		main.death()
