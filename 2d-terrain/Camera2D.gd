extends Camera2D

export(float) var speed = 150.0

var velocity = Vector2.ZERO

func _ready():
	pass

func _process(delta):
	velocity.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	global_position += velocity * speed * delta

