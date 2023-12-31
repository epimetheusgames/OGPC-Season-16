extends Node2D

var side1_pressed = false
var side2_pressed = false

export var moveable = true
export var moveable_color = Color(0, 0, 0, 0)
export var unmoveable_color = Color(0, 0, 0, 0)
export var transparent_moveable_color = Color(0, 0, 0, 0)
export var transparent_immoveable_color = Color(0, 0, 0, 0)
export var can_connect_with_immoveable = true
export var spacing = 10

var particle_explosion_reset = 0
var wire_ui = false
var tileset = null
var is_on_at_start = false
var placed_yet = false
var particles_list = []
var really_placed_yet = false
var added_particle_ind = 0

onready var sparks = $DupeHolder/DupeParticles2D
var poof = null

func _ready():
	if moveable:
		side1_pressed = true

	add_to_group("wires")
	
	move_button_to_line($Side1, 0)
	move_button_to_line($Side2, 1)
		
	if moveable:
		$Line2D.default_color = moveable_color
		$Side1IconImmoveable.visible = false
		$Side2IconImmoveable.visible = false
	else:
		$Side1Icon.visible = false
		$Side2Icon.visible = false
		$Line2D.default_color = unmoveable_color

func is_mouse_pressed():
	if Input.is_action_pressed("mouse_click"):
		return true 
	return false 
	
func distance(p1x, p1y, p2x, p2y):
	return sqrt(pow((p2x - p1x), 2) + pow((p2y - p1y), 2))
	
func move_button_and_line_to_mouse(button, side_num):
	$Line2D.points[side_num] = get_local_mouse_position()
	button.rect_position = get_local_mouse_position() - button.rect_size / 2
	
func move_button_to_line(button, side_num):
	button.rect_position = $Line2D.points[side_num] - button.rect_size / 2
	
func run_particles_down_wire(delete_other_emitters):
	if delete_other_emitters:
		for i in range(len(particles_list)):
			particles_list[i].emitting = false
			remove_child(particles_list[i])
			particles_list[i].queue_free()
		particles_list = []
	
	var pos_1 = $Line2D.points[0]
	var pos_2 = $Line2D.points[1]
	var start_to_end_dir = (pos_2 - pos_1).normalized()
	
	particles_list = []
	added_particle_ind = int(stepify(distance(pos_1.x, pos_1.y, pos_2.x, pos_2.y), 5))
	
	particle_explosion_reset = 500
	
func add_particle(i):
	var particle_instance = sparks.duplicate()
	var pos_1 = $Line2D.points[0]
	var pos_2 = $Line2D.points[1]
	var start_to_end_dir = (pos_2 - pos_1).normalized()
	particle_instance.position = pos_1 + (i * start_to_end_dir)
	particle_instance.emitting = true
	particle_instance.lifetime = (randi() % 50) + 5
	particle_instance.visible = true
	particles_list.append(particle_instance)
	add_child(particle_instance)

func _process(delta):
	if particle_explosion_reset > 0:
		particle_explosion_reset -= 1
	else:
		#for i in range(len(particles_list)):
		#	particles_list[i].emitting = false
		#	remove_child(particles_list[i])
		#	particles_list[i].queue_free()
		#particles_list = []
		pass
	
	if added_particle_ind > 0:
		added_particle_ind -= 5
		if added_particle_ind % spacing == 0:
			add_particle(added_particle_ind) 
	
	if wire_ui and moveable:
		$Line2D.default_color = moveable_color
	if not wire_ui and moveable:
		$Line2D.default_color = transparent_moveable_color
	if wire_ui and not moveable:
		$Line2D.default_color = unmoveable_color
	if not wire_ui and not moveable:
		$Line2D.default_color = transparent_immoveable_color
	
	$Line2D.points[0] = tileset.map_to_world(tileset.world_to_map($Line2D.points[0])) + tileset.cell_size / 2
	$Line2D.points[-1] = tileset.map_to_world(tileset.world_to_map($Line2D.points[-1])) + tileset.cell_size / 2
	
	var icon_size = Vector2($Side1Icon.texture.get_width(), $Side1Icon.texture.get_height())
	
	$Side1Icon.position = $Line2D.points[0] - icon_size / 2
	$Side2Icon.position = $Line2D.points[-1] - icon_size / 2
	$Side1IconImmoveable.position = $Line2D.points[0] - icon_size / 2
	$Side2IconImmoveable.position = $Line2D.points[-1] - icon_size / 2
		
	if wire_ui and moveable:
		$Side1Icon.visible = true 
		$Side2Icon.visible = true
	if wire_ui and not moveable:
		$Side1IconImmoveable.visible = true
		$Side2IconImmoveable.visible = true
	if not wire_ui and not moveable:
		$Side1IconImmoveable.visible = false
		$Side2IconImmoveable.visible = false
	if not wire_ui and moveable:
		$Side1Icon.visible = false 
		$Side2Icon.visible = false
		
	
	if side1_pressed:
		for child in get_children():
			if "Particles" in child.name and child != sparks and child != poof:
				child.queue_free()
		particles_list = []
		move_button_and_line_to_mouse($Side1, 0)
	elif side2_pressed:
		for child in get_children():
			if "Particles" in child.name:
				child.queue_free()
		particles_list = []
		move_button_and_line_to_mouse($Side2, 1)

func unselect():
	if side1_pressed or side2_pressed:
		queue_free()

func _on_Side1_button_down():
	if moveable and wire_ui:
		side1_pressed = true
		
		var pos = get_parent().get_parent().get_pos_on_tilemap($Line2D.points[0])
		var gs_or_n = get_parent().get_parent().is_spike_or_grass(pos)
		
		if placed_yet:
			if (gs_or_n == "n" and is_on_at_start) or (gs_or_n != "n" and not is_on_at_start):
				delete_tile_at(0, get_parent().get_node("TileMap"), true, get_parent().get_parent().deleted_spikes, get_parent().get_parent().deleted_spike_types)
				delete_tile_at(0, get_parent().get_node("Spikes_TileMap"), false, get_parent().get_parent().deleted_spikes, get_parent().get_parent().deleted_spike_types)

func _on_Side1_button_up():
	if moveable and wire_ui:
		if (get_parent().get_parent().is_point_on_connections($Line2D.points[0]) 
		   and not get_parent().get_parent().is_another_already_there(0, self) 
		   and not get_parent().get_parent().is_another_already_there(1, self)
		   and not (get_parent().get_parent().is_spike_or_grass(get_parent().get_parent().get_pos_on_tilemap($Line2D.points[-1])) == "s"
		   and get_parent().get_parent().is_spike_or_grass(get_parent().get_parent().get_pos_on_tilemap($Line2D.points[0])) == "s")):
			run_particles_down_wire(true)
			
			if not really_placed_yet:
				really_placed_yet = true
				run_particles_down_wire(false)
			
			var pos = get_parent().get_parent().get_pos_on_tilemap($Line2D.points[0])
			var gs_or_n = get_parent().get_parent().is_spike_or_grass(pos)
			
			if pos == get_parent().get_parent().get_pos_on_tilemap($Line2D.points[1]):
				queue_free()
			
			if gs_or_n == "n":
				is_on_at_start = false
			else:
				is_on_at_start = true
			
			placed_yet = true
			side1_pressed = false
		else:
			queue_free()
 
func _on_Side2_button_down():
	if moveable and wire_ui:
		side2_pressed = true

func _on_Side2_button_up():
	if moveable and wire_ui:
		if (get_parent().get_parent().is_point_on_connections($Line2D.points[-1]) 
		   and not get_parent().get_parent().is_another_already_there(1, self) 
		   and not get_parent().get_parent().is_another_already_there(0, self) 
		   and not (get_parent().get_parent().is_spike_or_grass(get_parent().get_parent().get_pos_on_tilemap($Line2D.points[-1])) == "s"
		   and get_parent().get_parent().is_spike_or_grass(get_parent().get_parent().get_pos_on_tilemap($Line2D.points[0])) == "s")):
			run_particles_down_wire(true)
			side2_pressed = false
		else:
			queue_free()
	
func is_selected():
	if side1_pressed or side2_pressed:
		return true 
	return false
	
func get_tileset_coords(point_ind, tileset):
	return tileset.world_to_map($Line2D.points[point_ind])
	
func get_touching_checkpoint(point_ind):
	var checkpoints = get_tree().get_nodes_in_group("checkpoints")
	
	for checkpoint in checkpoints:
		if checkpoint.is_point_inside($Line2D.points[point_ind]):
			return checkpoint
			
	return false
	
func get_touching_portal(point_ind):
	var portals = get_tree().get_nodes_in_group("portals")
	  
	for portal in portals:
		if portal.is_point_inside($Line2D.points[point_ind]):
			return [portal, portal.entrance]
			
	return false
	
func delete_tile_at(point_ind, tileset, is_grass, spike_coords, spike_coord_types):
	var pos = get_tileset_coords(point_ind, tileset)
	
	if tileset.get_cell(pos.x, pos.y) == -1 and is_grass and not pos in get_parent().get_parent().deleted_spikes:
		tileset.set_cell(pos.x, pos.y, 0)
	elif tileset.get_cell(pos.x, pos.y) != -1:
		var type = tileset.get_cell(pos.x, pos.y)
		tileset.set_cell(pos.x, pos.y, -1)
		if not is_grass:
			return [true, type, Vector2(pos.x, pos.y)]
	
	tileset.update_bitmask_region()

func set_pos(pos):
	$Line2D.points[0] = pos 
	$Line2D.points[-1] = pos
	$Side1.rect_position = pos - $Side1.rect_size / 2
	$Side2.rect_position = pos - $Side2.rect_size / 2


