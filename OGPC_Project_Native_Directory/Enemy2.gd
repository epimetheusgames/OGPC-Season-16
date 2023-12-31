extends KinematicBody2D


export var point1 = Vector2(0, 0)
export var point2 = Vector2(0, 0)
export var speed = 1

var going_to_point1 = false
var died = false


func distance(x1, y1, x2, y2):
	return sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2))

func _ready():
	add_to_group("enemy2group")

func _physics_process(delta):
	if going_to_point1:
		position += (point1 - point2).normalized() * speed
		if distance(position.x, position.y, point1.x, point1.y) < 10:
			going_to_point1 = false
	else:
		position += (point2 - point1).normalized() * speed
		if distance(position.x, position.y, point2.x, point2.y) < 10:
			going_to_point1 = true
	
	if died:
		remove_from_group("enemy2group")
		$CollisionShape2D.disabled = true
		visible = false 
		return
		
func die():
	died = true # Add support for death animation
