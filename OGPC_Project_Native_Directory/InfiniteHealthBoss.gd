extends KinematicBody2D


var attacking = false
var was_attacking = false
var was_attacked = false
var velocity = Vector2.ZERO
var died = false

var one_health_unit_in_image_scale
var attack_frames_length

export var gravity_strength = 10
export var friction_strength = 20
export var health = 100 # Can be changed


func _ready():
	$AttackTimer.start()
	attack_frames_length = len($AnimatedSprite.frames.frames)
	one_health_unit_in_image_scale = $Healthbar_Health.scale.x / health

func _physics_process(delta):
	Apply_Gravity()
	Apply_Friction()
	
	$Healthbar_Health.scale.x = one_health_unit_in_image_scale * health
	
	if died:
		$Healthbar_Health.scale.x = one_health_unit_in_image_scale
	
	if was_attacked:
		was_attacked = false
		velocity = Vector2(100, -30)
	
	if attacking:
		$AnimatedSprite.animation = "attacking"
		$AnimatedSprite.play() 
	else:
		$AnimatedSprite.animation = "idle"
		$AnimatedSprite.play()
	
	if not attacking and was_attacking:
		$AttackTimer.start()
		
	if $AnimatedSprite.frame == attack_frames_length + 2:
		attacking = false
		
	velocity = move_and_slide(velocity, Vector2.UP)
		
	var was_attacking = attacking
	
func Apply_Gravity():
	velocity.y += gravity_strength
	
func Apply_Friction():
	velocity.x = move_toward(velocity.x, 0, friction_strength)

func _on_AttackTimer_timeout():
	attacking = true
	
# In the future this will be and connection from the player bullet when it damages the enemy.
func on_Knockback_event():
	#$AnimatedSprite.animation = "damaged"
	health -= 1
	if health <= 0:
		died = true
	attacking = false
	was_attacked = true 
 
