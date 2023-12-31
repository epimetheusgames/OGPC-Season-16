extends KinematicBody2D


var velocity = Vector2(0, 0)
var speed = 0.1
var speed_scaling_amount = 20
var has_been_fired = false
var self_position


const shockwave_file_path = preload("res://Player_Bullet_Shockwave.tscn")

onready var player_body = get_parent().get_node("Player_Body")


func _physics_process(_delta):
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	var bullet_collision_info = move_and_collide(velocity)
	
	if bullet_collision_info != null:
		# play the SFX for the shockwave explosion
		get_node("/root/MainMenuRootNode/Shockwave_Explosion_SFX_Player").play()
		# spawn the shockwave
		Spawn_Shockwave()
		self_position = Vector2(self.position.x, self.position.y)
		self.queue_free()
		for enemy in enemies:
			pass # check for if the bullet hit this specific enemy, if so, set enemy.died to true.
	
	speed += speed_scaling_amount
	
	if has_been_fired == false:
		velocity = Vector2(get_global_mouse_position() - player_body.position).normalized() * speed
		
		has_been_fired = true

func Spawn_Shockwave():
	var player_bullet_shockwave = shockwave_file_path.instance()
	
	get_parent().add_child(player_bullet_shockwave)
	
	var player_bullet_shockwave_position = player_bullet_shockwave.position
	
	player_bullet_shockwave.position = self.position
