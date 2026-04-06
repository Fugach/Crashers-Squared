extends Node2D

@onready var Slot1 : AnimatedSprite2D = $slot1
@onready var Slot2 : AnimatedSprite2D = $slot2
@onready var Slot3 : AnimatedSprite2D = $slot3

func _ready() -> void:
	update()

func update():
	Slot1.play(GlobalVars.slots["slot1"])
	Slot2.play(GlobalVars.slots["slot2"])
	Slot3.play(GlobalVars.slots["slot3"])
