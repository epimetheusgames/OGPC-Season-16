extends Node2D


var opacity = 0 
var sin_val = 0 
var list_ind = 0
var color_rect_brightness = -0.3

export var text_list = []

func _process(delta):
	opacity = sin(deg2rad(sin_val))
	sin_val += 10

	$Label.modulate = Color(1, 1, 1, opacity)
		
	if sin_val % 360 == 0 and sin_val != 0:
		list_ind += 1
		
	if sin_val / 360 >= len(text_list):
		list_ind = len(text_list) - 1
	
	if list_ind >= len(text_list) - 1:
		$ColorRect.color = Color(color_rect_brightness, color_rect_brightness, color_rect_brightness)
		color_rect_brightness += 0.0035
		
		if color_rect_brightness > 1.3:
			get_parent().next_level()
		
		$Label.modulate = Color(1, 1, 1, 1)
		
	$Label.text = text_list[list_ind]
	
