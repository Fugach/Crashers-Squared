extends TileMapLayer

const ENEMY = preload("uid://x2aibfdis1lc")
@onready var Elevator : Area2D = $"../Elevator"


var room_anchor = Vector2(0, 0)
var room_size = Vector2(0, 0)
var room_doors = ""
var doors_height = 0
var hall_length = 0
var hall_tilt = 0
var old_room_size = Vector2(0, 0)
var old_room_doors_height = 0
var old_room_anchor = Vector2(0, 0)
var stairs_length : int = 0
var gen_direction := Vector2(0, 0)
var hall_pos1 = Vector2(0, 0)
var hall_pos2 = Vector2(0, 0)
var total_enemies : int = 0


func _ready() -> void:
	var rooms_amount = randi_range(3, 15)
	gen_dungeon(rooms_amount)

func gen_dungeon(rooms_amount):
	clear()
	$"../UI/HUD/TABLE/table/Button".disabled = false
	for body in get_parent().get_children():
		if body is RigidBody2D or "Enemy" in str(body) or "Rocket" in str(body) or "Bullet" in str(body):
			body.queue_free()
	$bg.clear()
	
	print("Generating ", str(rooms_amount),  " rooms")
	
	room_anchor = Vector2(3, 2)
	room_size = Vector2(15, 8)
	gen_direction.x = [-1, 1].pick_random()
	print("Generation direction: ", gen_direction)
	#gen_direction.x = 1
	
	if gen_direction.x == 1:
		room_doors = "right"
	elif gen_direction.x == -1: 
		room_doors = "left"
	doors_height = randi_range(-2, 2)
	
	generate_room(room_anchor, room_size, room_doors, doors_height, false)
	
	for o in range(rooms_amount):
		old_room_anchor = room_anchor
		old_room_size = room_size
		old_room_doors_height = doors_height
		
		room_size = Vector2(randi_range(10, 20), randi_range(8, 15))
		if gen_direction.x == 1:
			room_anchor += Vector2(old_room_size.x + 5, old_room_size.y - room_size.y)
		elif gen_direction.x == -1:
			room_anchor += Vector2(-5 + room_size.x * -1, old_room_size.y - room_size.y)
		
		if o != rooms_amount - 1:
			generate_room(room_anchor, room_size, "both", doors_height, true)
			if gen_direction.x == 1:
				hall_pos1 = old_room_anchor + old_room_size
				hall_pos2 = room_anchor + Vector2(0, room_size.y)
				generate_hall(hall_pos1, hall_pos2)
				#set_cell(hall_pos1, 0, Vector2(0, 1))
				#set_cell(hall_pos2, 0, Vector2(0, 2))
			elif gen_direction.x == -1:
				hall_pos1 = room_anchor + room_size
				hall_pos2 = old_room_anchor + Vector2(0, old_room_size.y)
				generate_hall(hall_pos1, hall_pos2)
				#set_cell(hall_pos1, 0, Vector2(0, 1))
				#set_cell(hall_pos2, 0, Vector2(0, 2))
		else:
			if gen_direction.x == 1:
				Elevator.global_position = (room_anchor - Vector2(3, 1) + room_size) * Vector2(16, 16)
				generate_room(room_anchor, room_size, "left", doors_height, true)
				hall_pos1 = old_room_anchor + old_room_size
				hall_pos2 = room_anchor + Vector2(0, room_size.y)
				generate_hall(hall_pos1, hall_pos2)
			elif gen_direction.x == -1:
				Elevator.global_position = (room_anchor + Vector2(4, room_size.y - 1)) * Vector2(16, 16)
				generate_room(room_anchor, room_size, "right", doors_height, true)
				hall_pos1 = room_anchor + room_size
				hall_pos2 = old_room_anchor + Vector2(0, old_room_size.y)
				generate_hall(hall_pos1, hall_pos2)
	
	print("Generation is finished")
	$tada.play()

func generate_room(pos, size, doors, height, enemies):
	#for x in range(size.x):
		#set_cell(pos + Vector2(x, 0), 0, Vector2(6, 0))
		#set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(x, 0)), 0, 0, false)
		#set_cell(pos + Vector2(x, size.y), 0, Vector2(6, 0))
		#set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(x, size.y)), 0, 0, false)
	#for y in range(size.y):
		#set_cell(pos + Vector2(0, y), 0, Vector2(6, 0))
		#set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(0, y)), 0, 0, false)
		#set_cell(pos + Vector2(size.x, y), 0, Vector2(6, 0))
		#set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(size.x, y)), 0, 0, false)
	#set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(size.x, 0)), 0, 0, false)
	#set_cells_terrain_connect(get_surrounding_cells(pos + size), 0, 0, false)
	#for x in range(size.x):
		#for y in range(size.y):
			#$bg.set_cell(pos + Vector2(x, y), 0, Vector2(0, 0))
	#
	#
	#if  doors == "left" or doors == "both":
		#var vhod1_size = Vector2(3, 2)
		#var vhod1_pos = pos + Vector2(-1, size.y + height - 3)
		#for y in range(vhod1_size.y):
			#for x in range(vhod1_size.x):
				#erase_cell(vhod1_pos + Vector2(x, y))
				#if x == vhod1_size.x - 1:
					#$bg.set_cell(vhod1_pos + Vector2(x, y), 0, Vector2(0, 0))
				#else:
					#$bg.set_cell(vhod1_pos + Vector2(x, y), 0, Vector2(1, 0))
		#set_cell(vhod1_pos + Vector2(0, 2), 1, Vector2(5, 1))
		#set_cell(vhod1_pos + Vector2(1, 2), 1, Vector2(1, 2))
		#if height != 0:
			#set_cell(vhod1_pos + Vector2(2, 2), 1, Vector2(4, 1))
		#else:
			#set_cell(vhod1_pos + Vector2(2, 2), 1, Vector2(1, 0))
		##var new_door = door.instantiate()
		##new_door.global_position = (vhod1_pos - Vector2(2, 2)) * Vector2(32, 32)
		##get_parent().add_child.call_deferred(new_door)
#
		#if height != 0:
			#if false:
				## OLD CODE DISABLED RN
				#for i in range(height * -1):
					#set_cell(Vector2(vhod1_pos.x + vhod1_size.x + i, vhod1_pos.y - vhod1_size.y + 1 + i), 1, Vector2(7, 2))
				#if height == -2:
					#set_cells_terrain_connect(get_surrounding_cells(Vector2(vhod1_pos.x + vhod1_size.x - 1, vhod1_pos.y - vhod1_size.y + abs(height)))\
					#, 0, 0, false)
			#else:
				#for i in range(height * -1):
					#set_cell(Vector2(vhod1_pos.x + vhod1_size.x + i * 2, vhod1_pos.y - vhod1_size.y + 4 + i), 1, Vector2(8, 2))
					#set_cell(Vector2(vhod1_pos.x + vhod1_size.x + i * 2, vhod1_pos.y - vhod1_size.y + 5 + i), 1, Vector2(1, 1))
					#
					#set_cell(Vector2(vhod1_pos.x + vhod1_size.x + 1 + i * 2, vhod1_pos.y - vhod1_size.y + 4 + i), 1, Vector2(9, 2))
					#set_cell(Vector2(vhod1_pos.x + vhod1_size.x + 1 + i * 2, vhod1_pos.y - vhod1_size.y + 5 + i), 1, Vector2(1, 1))
					#
					#if i == height * -1 -1:
						#set_cell(Vector2(vhod1_pos.x + vhod1_size.x + i * 2, vhod1_pos.y - vhod1_size.y + 5 + i), 1, Vector2(4, 0))
						#set_cell(Vector2(vhod1_pos.x + vhod1_size.x + 1 + i * 2, vhod1_pos.y - vhod1_size.y + 5 + i), 1, Vector2(4, 0))
	#if doors == "right" or doors == "both":
		#var vhod2_size = Vector2(3, 2)
		#var vhod2_pos = size + pos + Vector2(-1, height - 3)
		#for y in range(vhod2_size.y):
			#for x in range(vhod2_size.x):
				#erase_cell(vhod2_pos + Vector2(x, y))
				#if x == 0:
					#$bg.set_cell(vhod2_pos + Vector2(x, y), 0, Vector2(0, 0))
				#else:
					#$bg.set_cell(vhod2_pos + Vector2(x, y), 0, Vector2(1, 0))
		#
		##var new_door = door.instantiate()
		##new_door.global_position = (vhod2_pos + Vector2(1, 1)) * Vector2(32, 32)
		##get_parent().add_child.call_deferred(new_door)
#
		#if height != 0:
			#if false:
				#for i in range(height * -1):
					#set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 1 - i, vhod2_pos.y - vhod2_size.y + 1 + i), 1, Vector2(9, 1))
				#if height == -2:
					#set_cells_terrain_connect(get_surrounding_cells(Vector2(vhod2_pos.x + vhod2_size.x, vhod2_pos.y - vhod2_size.y + abs(height)))\
					#, 0, 0, false)
			#else:
				#for i in range(height * -1):
					#set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 4 - i * 2, vhod2_pos.y - vhod2_size.y + 4 + i), 1, Vector2(8, 1))
					#set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 4 - i * 2, vhod2_pos.y - vhod2_size.y + 5 + i), 1, Vector2(1, 1))
#
					#set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 5 - i * 2, vhod2_pos.y - vhod2_size.y + 4 + i), 1, Vector2(7, 1))
					#set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 5 - i * 2, vhod2_pos.y - vhod2_size.y + 5 + i), 1, Vector2(1, 1))
					#if i == height * -1 -1:
						#set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 5 - i * 2, vhod2_pos.y - vhod2_size.y + 5 + i), 1, Vector2(4, 0))
						#set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 4 - i * 2, vhod2_pos.y - vhod2_size.y + 5 + i), 1, Vector2(4, 0))
	for x in range(size.x):
		if x == 0:
			set_cell(pos + Vector2(x, -1), 0, Vector2(6, 0))
			set_cell(pos + Vector2(x, size.y + 1), 0, Vector2(6, 0))
			set_cell(pos + Vector2(size.x, -1), 0, Vector2(6, 0))
			set_cell(pos + Vector2(size.x, size.y + 1), 0, Vector2(6, 0))
			
			set_cell(pos + Vector2(x, 0), 0, Vector2(3, 3))
			set_cell(pos + Vector2(x, size.y), 0, Vector2(3, 4))
			
			set_cell(pos + Vector2(x, -2), 0, Vector2(8, 1))
			set_cell(pos + Vector2(x, size.y + 2), 0, Vector2(7, 1))
			continue
		set_cell(pos + Vector2(x, -1), 0, Vector2(6, 0))
		set_cell(pos + Vector2(x, size.y + 1), 0, Vector2(6, 0))
		
		set_cell(pos + Vector2(x, 0), 0, Vector2(1, 2))
		set_cell(pos + Vector2(x, size.y), 0, Vector2(2, 2))
		set_cell(pos + Vector2(x, -2), 0, Vector2(8, 1))
		set_cell(pos + Vector2(x, size.y + 2), 0, Vector2(7, 1))
	for y in range(size.y):
		if y == 0:
			set_cell(pos + Vector2(size.x + 1, y), 0, Vector2(6, 0))
			set_cell(pos + Vector2(size.x + 1, size.y), 0, Vector2(6, 0))
			set_cell(pos + Vector2(-1, y), 0, Vector2(6, 0))
			set_cell(pos + Vector2(-1, size.y), 0, Vector2(6, 0))
			
			set_cell(pos + Vector2(size.x, y), 0, Vector2(4, 3))
			set_cell(pos + Vector2(size.x, size.y), 0, Vector2(4, 4))
			
			set_cell(pos + Vector2(-2, y), 0, Vector2(7, 2))
			set_cell(pos + Vector2(size.x + 2, y), 0, Vector2(8, 2))
			continue
		set_cell(pos + Vector2(size.x + 1, y), 0, Vector2(6, 0))
		set_cell(pos + Vector2(-1, y), 0, Vector2(6, 0))
		
		set_cell(pos + Vector2(0, y), 0, Vector2(3, 2))
		set_cell(pos + Vector2(size.x, y), 0, Vector2(4, 2))
		set_cell(pos + Vector2(-2, y), 0, Vector2(7, 2))
		set_cell(pos + Vector2(size.x + 2, y), 0, Vector2(8, 2))
	
	for x in range(size.x):
		for y in range(size.y):
			$bg.set_cell(pos + Vector2(x, y), 0, Vector2(0, 0))
	
	set_cell(pos + Vector2(-1, -1), 0, Vector2(6, 0))
	set_cell(pos + Vector2(-1, size.y + 1), 0, Vector2(6, 0))
	set_cell(pos + Vector2(size.x + 1, -1), 0, Vector2(6, 0))
	set_cell(pos + size + Vector2(1, 1), 0, Vector2(6, 0))
	
	set_cell(pos + Vector2(-2, -1), 0, Vector2(7, 2))
	set_cell(pos + Vector2(-1, -2), 0, Vector2(8, 1))
	set_cell(pos + Vector2(-2, -2), 0, Vector2(8, 3))
	
	set_cell(pos + size + Vector2(2, 0), 0, Vector2(8, 2))
	set_cell(pos + size + Vector2(2, 1), 0, Vector2(8, 2))
	set_cell(pos + size + Vector2(0, 2), 0, Vector2(7, 1))
	set_cell(pos + size + Vector2(1, 2), 0, Vector2(7, 1))
	set_cell(pos + size + Vector2(2, 2), 0, Vector2(7, 3))
	
	set_cell(pos + Vector2(-1, size.y + 2), 0, Vector2(7, 1))
	set_cell(pos + Vector2(-2, size.y + 1), 0, Vector2(7, 2))
	set_cell(pos + Vector2(-2, size.y), 0, Vector2(7, 2))
	set_cell(pos + Vector2(-2, size.y + 2), 0, Vector2(7, 4))
	
	set_cell(pos + Vector2(size.x + 1, -2), 0, Vector2(8, 1))
	set_cell(pos + Vector2(size.x, -2), 0, Vector2(8, 1))
	set_cell(pos + Vector2(size.x + 2, -1), 0, Vector2(8, 2))
	set_cell(pos + Vector2(size.x + 2, -2), 0, Vector2(8, 4))
	
	#if enemies:
		#for x in range(randi_range(1, 5)):
			#var new_enemy = ENEMY.instantiate()
			#new_enemy.global_position = pos + Vector2(room_size.x / 2, -5)
			#new_enemy.name = "Enemy" + str(total_enemies)
			#total_enemies += 1
			#print(new_enemy)
			#get_parent().add_child.call_deferred(new_enemy)
	
func generate_hall(pos1, pos2):
	for x in range(3):
		for y in range(3):
			erase_cell(pos1 + Vector2(x, y - 3))
			$bg.set_cell(pos1 + Vector2(x, y - 3), 0, Vector2(1, 0))
	set_cell(pos1 + Vector2(0, -4), 0, Vector2(6, 1))
	set_cell(pos1 + Vector2(1, -4), 0, Vector2(1, 2))
	set_cell(pos1 + Vector2(2, -4), 0, Vector2(9, 1))
	set_cell(pos1 + Vector2(0, 0), 0, Vector2(2, 2))
	set_cell(pos1 + Vector2(1, 0), 0, Vector2(2, 2))
	set_cell(pos1 + Vector2(2, 0), 0, Vector2(2, 2))
	for x in range(3):
		for y in range(3):
			erase_cell(pos2 + Vector2(x - 2, y - 3))
			$bg.set_cell(pos1 + Vector2(x + 3, y - 3), 0, Vector2(1, 0))
	set_cell(pos2 + Vector2(0, -4), 0, Vector2(5, 1))
	set_cell(pos2 + Vector2(-1, -4), 0, Vector2(1, 2))
	set_cell(pos2 + Vector2(-2, -4), 0, Vector2(9, 2))
	set_cell(pos2 + Vector2(0, 0), 0, Vector2(2, 2))
	set_cell(pos2 + Vector2(-1, 0), 0, Vector2(2, 2))
	set_cell(pos2 + Vector2(-2, 0), 0, Vector2(2, 2))


func _on_animation_player_current_animation_changed(name: StringName) -> void:
	Elevator.results()
