extends Node2D

var selected = 1
var prev_selected = 1

func _process(delta):
	if Input.is_action_just_pressed("Just_Arrowkey_Down"):
		if selected < 3:
			selected += 1
	if Input.is_action_just_pressed("Just_Arrowkey_Up"):
		if selected > 1:
			selected -= 1
			
	if prev_selected != selected:
		get_parent().Play_Click_SFX()
			
	if selected == 1:
		#$Label.text = "- Play -"
		$Label.modulate = Color(2.75, 2.75, 2.75, 1)
		#$Label2.text = "Options"
		$Label2.modulate = Color(1, 1, 1, 1)
	if selected == 2:
		#$Label2.text = "- Options -"
		$Label2.modulate = Color(2.75, 2.75, 2.75, 1) 
		#$Label.text = "Play"
		$Label.modulate = Color(1, 1, 1, 1)
		#$Label3.text = "Quit"
		$Label3.modulate = Color(1, 1, 1, 1)
	if selected == 3:
		#$Label2.text = "Options"
		$Label2.modulate = Color(1, 1, 1, 1)
		#$Label3.text = "- Quit -"
		$Label3.modulate = Color(2.75, 2.75, 2.75, 1)
	
	if Input.is_action_just_pressed("ui_accept"):
		option_selected()
	
	prev_selected = selected


func option_selected():
	get_parent().Play_Click_SFX()
	if selected == 1:
		get_parent().Close_Pause_Menu(self)
	if selected == 2:
		get_parent().Open_Options_Menu(self)
	if selected == 3:
		get_parent().Close_Pause_Menu_To_Main(self)

func _on_ResumeButton_button_up():
	selected = 1
	option_selected()

func _on_OptionsButton_button_up():
	selected = 2
	option_selected()

func _on_ExitButton_button_up():
	selected = 3
	option_selected()
