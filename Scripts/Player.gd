extends Area2D

@export var WALKING_SPEED = 180
@export var STARTING_POS  = Vector2(0,0)
var screen_size 
var x_direction = 0
var y_direction = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#hide()
	screen_size = get_viewport_rect().size
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_just_pressed("move_right") and x_direction == 0:
		x_direction =  1
		y_direction =  0
	if Input.is_action_just_pressed("move_left")  and x_direction == 0:
		x_direction = -1
		y_direction =  0
	if Input.is_action_just_pressed("move_down")  and y_direction == 0:
		x_direction =  0
		y_direction =  1
	if Input.is_action_just_pressed("move_up")    and y_direction == 0:
		x_direction =  0
		y_direction = -1
		
	velocity = WALKING_SPEED * Vector2(x_direction, y_direction)

	if not(velocity == Vector2.ZERO):
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta
	position  = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		# TODO: replace "placeholder" with "walk" animation
		$AnimatedSprite2D.animation = "placeholder"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		# TODO: replace "placeholder" with "up" animation
		$AnimatedSprite2D.animation = "placeholder"
		#$AnimatedSprite2D.flip_v = velocity.y > 0
	return
