extends TileMapLayer

@onready var door = preload("res://door.tscn")
@onready var enemy = preload("res://enemy.tscn")

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
var gen_direction = ""
var hall_pos1 = Vector2(0, 0)
var hall_pos2 = Vector2(0, 0)
func _ready() -> void:
	# generating first room
	room_anchor = Vector2(3, 2)
	room_size = Vector2(15, 8)
	gen_direction = ["left", "right"].pick_random()
	#gen_direction = "right"
	if gen_direction == "right":
		room_doors = "right"
	else: 
		room_doors = "left"
	doors_height = randi_range(-2, 0)
	generate_room(room_anchor, room_size, room_doors, doors_height, false)
	
	gen_dungeon(randi_range(3, 15))
	#$AudioStreamPlayer2D.play()

func gen_dungeon(rooms_count):
	for o in range(rooms_count):
		old_room_size = room_size
		old_room_doors_height = doors_height
		old_room_anchor = room_anchor
		
		room_size.x = randi_range(12, 25)
		room_size.y = randi_range(10, 15)
		
		if gen_direction == "right": 
			room_anchor.x += old_room_size.x
		elif gen_direction == "left":
			room_anchor.x -= room_size.x
		room_anchor.y += (old_room_size.y - room_size.y)
		
		hall_length = randi_range(5, 12)
		doors_height = randi_range(-2, 0)
		hall_tilt = 0
		#while true:
			#if (hall_tilt + doors_height + old_room_doors_height - 1) != 0:
				#if (room_anchor.x + Vector2(hall_length * -1, hall_tilt)) % (hall_tilt + doors_height + old_room_doors_height - 1) != 0:
					#hall_tilt = randi_range(hall_length * -1, hall_length)
					#hall_length = randi_range(5, 12)
				#else:
					#break
			#else:
				#break
		print("delta: ", hall_tilt + doors_height + old_room_doors_height, " len: ", hall_length)
		if gen_direction == "right":
			room_anchor += Vector2(hall_length + 3, hall_tilt)
		elif gen_direction == "left":
			room_anchor += Vector2(hall_length * -1, hall_tilt)
		
		if gen_direction == "right":
			hall_pos1 = old_room_anchor + old_room_size + Vector2(2, old_room_doors_height - 1)
			hall_pos2 = room_anchor + Vector2(0, doors_height + room_size.y - 1)
		elif gen_direction == "left":
			hall_pos1 = room_anchor + room_size + Vector2(2, doors_height - 1)
			hall_pos2 = old_room_anchor + Vector2(-2, old_room_doors_height + old_room_size.y - 1)
		
		if gen_direction == "right":
			generate_hall(hall_pos1, hall_pos2)
		elif gen_direction == "left":
			generate_hall(hall_pos1, hall_pos2)
		
		if o != rooms_count - 1:
			generate_room(room_anchor, room_size, "both", doors_height, true)
		else:
			if gen_direction == "right":
				generate_room(room_anchor, room_size, "left", doors_height, true)
			elif gen_direction == "left":
				generate_room(room_anchor, room_size, "right", doors_height, true)
		#set_cell(hall_pos1, 1, Vector2(0, 4))
		#set_cell(hall_pos2, 1, Vector2(0, 5))

func generate_room(pos, size, doors, height, enemies):
	for x in range(size.x):
		set_cell(pos + Vector2(x, 0), 1, Vector2(0, 3))
		set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(x, 0)), 0, 0, false)
		set_cell(pos + Vector2(x, size.y), 1, Vector2(0, 3))
		set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(x, size.y)), 0, 0, false)
	for y in range(size.y):
		set_cell(pos + Vector2(0, y), 1, Vector2(0, 3))
		set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(0, y)), 0, 0, false)
		set_cell(pos + Vector2(size.x, y), 1, Vector2(0, 3))
		set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(size.x, y)), 0, 0, false)
	set_cells_terrain_connect(get_surrounding_cells(pos + Vector2(size.x, 0)), 0, 0, false)
	set_cells_terrain_connect(get_surrounding_cells(pos + size), 0, 0, false)
	for x in range(size.x):
		for y in range(size.y):
			$bg.set_cell(pos + Vector2(x, y), 0, Vector2(0, 0))
	
	
	if  doors == "left" or doors == "both":
		var vhod1_size = Vector2(3, 2)
		var vhod1_pos = pos + Vector2(-1, size.y + height - 3)
		for y in range(vhod1_size.y):
			for x in range(vhod1_size.x):
				erase_cell(vhod1_pos + Vector2(x, y))
				if x == vhod1_size.x - 1:
					$bg.set_cell(vhod1_pos + Vector2(x, y), 0, Vector2(0, 0))
				else:
					$bg.set_cell(vhod1_pos + Vector2(x, y), 0, Vector2(1, 0))
		set_cell(vhod1_pos + Vector2(0, 2), 1, Vector2(5, 1))
		set_cell(vhod1_pos + Vector2(1, 2), 1, Vector2(1, 2))
		if height != 0:
			set_cell(vhod1_pos + Vector2(2, 2), 1, Vector2(4, 1))
		else:
			set_cell(vhod1_pos + Vector2(2, 2), 1, Vector2(1, 0))
		#var new_door = door.instantiate()
		#new_door.global_position = (vhod1_pos - Vector2(2, 2)) * Vector2(32, 32)
		#get_parent().add_child.call_deferred(new_door)

		if height != 0:
			if false:
				# OLD CODE DISABLED RN
				for i in range(height * -1):
					set_cell(Vector2(vhod1_pos.x + vhod1_size.x + i, vhod1_pos.y - vhod1_size.y + 1 + i), 1, Vector2(7, 2))
				if height == -2:
					set_cells_terrain_connect(get_surrounding_cells(Vector2(vhod1_pos.x + vhod1_size.x - 1, vhod1_pos.y - vhod1_size.y + abs(height)))\
					, 0, 0, false)
			else:
				for i in range(height * -1):
					set_cell(Vector2(vhod1_pos.x + vhod1_size.x + i * 2, vhod1_pos.y - vhod1_size.y + 4 + i), 1, Vector2(8, 2))
					set_cell(Vector2(vhod1_pos.x + vhod1_size.x + i * 2, vhod1_pos.y - vhod1_size.y + 5 + i), 1, Vector2(1, 1))
					
					set_cell(Vector2(vhod1_pos.x + vhod1_size.x + 1 + i * 2, vhod1_pos.y - vhod1_size.y + 4 + i), 1, Vector2(9, 2))
					set_cell(Vector2(vhod1_pos.x + vhod1_size.x + 1 + i * 2, vhod1_pos.y - vhod1_size.y + 5 + i), 1, Vector2(1, 1))
					
					if i == height * -1 -1:
						set_cell(Vector2(vhod1_pos.x + vhod1_size.x + i * 2, vhod1_pos.y - vhod1_size.y + 5 + i), 1, Vector2(4, 0))
						set_cell(Vector2(vhod1_pos.x + vhod1_size.x + 1 + i * 2, vhod1_pos.y - vhod1_size.y + 5 + i), 1, Vector2(4, 0))
	if doors == "right" or doors == "both":
		var vhod2_size = Vector2(3, 2)
		var vhod2_pos = size + pos + Vector2(-1, height - 3)
		for y in range(vhod2_size.y):
			for x in range(vhod2_size.x):
				erase_cell(vhod2_pos + Vector2(x, y))
				if x == 0:
					$bg.set_cell(vhod2_pos + Vector2(x, y), 0, Vector2(0, 0))
				else:
					$bg.set_cell(vhod2_pos + Vector2(x, y), 0, Vector2(1, 0))
		
		#var new_door = door.instantiate()
		#new_door.global_position = (vhod2_pos + Vector2(1, 1)) * Vector2(32, 32)
		#get_parent().add_child.call_deferred(new_door)

		if height != 0:
			if false:
				for i in range(height * -1):
					set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 1 - i, vhod2_pos.y - vhod2_size.y + 1 + i), 1, Vector2(9, 1))
				if height == -2:
					set_cells_terrain_connect(get_surrounding_cells(Vector2(vhod2_pos.x + vhod2_size.x, vhod2_pos.y - vhod2_size.y + abs(height)))\
					, 0, 0, false)
			else:
				for i in range(height * -1):
					set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 4 - i * 2, vhod2_pos.y - vhod2_size.y + 4 + i), 1, Vector2(8, 1))
					set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 4 - i * 2, vhod2_pos.y - vhod2_size.y + 5 + i), 1, Vector2(1, 1))

					set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 5 - i * 2, vhod2_pos.y - vhod2_size.y + 4 + i), 1, Vector2(7, 1))
					set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 5 - i * 2, vhod2_pos.y - vhod2_size.y + 5 + i), 1, Vector2(1, 1))
					if i == height * -1 -1:
						set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 5 - i * 2, vhod2_pos.y - vhod2_size.y + 5 + i), 1, Vector2(4, 0))
						set_cell(Vector2(vhod2_pos.x + vhod2_size.x - 4 - i * 2, vhod2_pos.y - vhod2_size.y + 5 + i), 1, Vector2(4, 0))
	if enemies:
		for x in range(randi_range(1, 16)):
			var new_enemy = enemy.instantiate()
			if gen_direction == "left":
				new_enemy.global_position = (pos + size) * 16 + Vector2(randi_range(-5, -15), 3) * 16
			elif gen_direction == "right":
				new_enemy.global_position = (pos + size) * 16
			#get_tree().current_scene.add_child.call_deferred(new_enemy)
func generate_hall(pos1, pos2):
	if pos1.y - pos2.y == 0:
		for x in (abs(pos1.x - pos2.x) + 1):
			set_cell(pos1 + Vector2(x, 0), 1, Vector2(4, 0))
			set_cell(pos1 + Vector2(x, -3), 1, Vector2(4, 0))
			for y in range(2):
				$bg.set_cell(Vector2(pos1 + Vector2(x, -1 + y * -1)), 0, Vector2(1, 0))
	else:
		var points_delta = pos1.y - pos2.y
		var num_stairs : int = abs(points_delta) + 1
		var stair_len : int = round((abs(pos1.x - pos2.x) + 1) / num_stairs)
		print(num_stairs, " ", stair_len, " pos1 == ", pos1, " pos2 == ", pos2)
		for y in range(num_stairs):
			for x in range(stair_len):
				for bgy in range(4):
					$bg.set_cell(Vector2(pos1 + Vector2(x + (stair_len * y), y * -1 * sign(points_delta) - bgy)), 0, Vector2(1, 0))
				set_cell(pos1 + Vector2(x + (stair_len * y), y * -1 * sign(points_delta)), 1, Vector2(4, 0))
				set_cell(pos1 + Vector2(x + (stair_len * y), y * -1 * sign(points_delta) - 4), 1, Vector2(4, 0))
				if x == stair_len -1 and y != num_stairs - 1:
					if points_delta > 0:
						set_cell(pos1 + Vector2(x + (stair_len * y), y * -1 * sign(points_delta) - 1), 1, Vector2(9, 1))
						set_cell(pos1 + Vector2(x + (stair_len * y), y * -1 * sign(points_delta) - 5), 1, Vector2(9, 1))
					elif points_delta < 0:
						set_cell(pos1 + Vector2(x + 1 + (stair_len * y), y * -1 * sign(points_delta)), 1, Vector2(7, 2))
						set_cell(pos1 + Vector2(x + 1 + (stair_len * y), y * -1 * sign(points_delta) - 4), 1, Vector2(7, 2))
