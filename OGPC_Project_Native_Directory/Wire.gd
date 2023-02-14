extends Node2D

var side1_pressed = false
var side2_pressed = false

func _ready():
	add_to_group("wires")

func is_mouse_pressed():
	if Input.is_action_pressed("mouse_click"):
		return true 
	return false 
	
func move_button_and_line_to_mouse(button, side_num):
	$Line2D.points[side_num] = get_local_mouse_position()
	button.rect_position = get_local_mouse_position() - button.rect_size / 2

func _process(delta):
	if side1_pressed:
		move_button_and_line_to_mouse($Side1, 0)
	elif side2_pressed:
		move_button_and_line_to_mouse($Side2, 1)
		
	if not is_mouse_pressed():
		side1_pressed = false
		side2_pressed = false

func _on_Side1_button_down():
	side1_pressed = true

func _on_Side1_button_up():
	side1_pressed = false

func _on_Side2_button_down():
	side2_pressed = true

func _on_Side2_button_up():
	side2_pressed = false
	
func is_selected():
	if side1_pressed or side2_pressed:
		return true 
	return false
	
func get_tileset_coords(point_ind, tileset):
	return tileset.world_to_map($Line2D.points[point_ind])
	
func delete_tile_at(point_ind, tileset, is_grass):
	var pos = get_tileset_coords(point_ind, tileset)
	
	if tileset.get_cell(pos.x, pos.y) == -1 and is_grass:
		tileset.set_cell(pos.x, pos.y, 0)
	else:
		tileset.set_cell(pos.x, pos.y, -1)
		
	tileset.update_bitmask_region()

func set_pos(pos):
	$Line2D.points[0] = pos 
	$Line2D.points[1] = pos
	$Side1.rect_position = pos - $Side1.rect_size / 2
	$Side2.rect_position = pos - $Side2.rect_size / 2
