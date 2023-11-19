extends Area2D

signal hit_house
signal hit_car

@export var WALKING_SPEED = 180
@export var STARTING_POS  = Vector2(0,0)
var screen_size 
var x_direction = 0
var y_direction = 0
var direction = Vector2.ZERO
var velocity = Vector2.ZERO # The player's movement vector.
var old_pos = Vector2.ZERO

# bounce stuff
var bouncing = false
var inputTimeout = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	#hide()
	#try_wait()
	screen_size = get_viewport_rect().size
	return

func check_input():
	if(bouncing):
		return
	if Input.is_action_just_pressed("move_right") and x_direction == 0:
		direction = Vector2(1, 0)
		#x_direction =  1
		#y_direction =  0
	if Input.is_action_just_pressed("move_left")  and x_direction == 0:
		direction = Vector2(-1, 0)
		#x_direction = -1
		#y_direction =  0
	if Input.is_action_just_pressed("move_down")  and y_direction == 0:
		direction = Vector2(0, 1)
		#x_direction =  0
		#y_direction =  1
	if Input.is_action_just_pressed("move_up")    and y_direction == 0:
		direction = Vector2(0, -1)
		#x_direction =  0
		#y_direction = -1
	# direction = Vector2(x_direction, y_direction)
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print($CollisionShape2D.disabled)
	old_pos = position
	velocity = Vector2.ZERO # The player's movement vector.
	check_input()
	#x_direction = direction[0]
	#y_direction = direction[1]
	#velocity = WALKING_SPEED * Vector2(x_direction, y_direction)
	velocity = WALKING_SPEED * direction	

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

func bounce():
	try_wait()
	return
	
func try_wait():
	bouncing = true
	direction = (old_pos - position).normalized()
	await get_tree().create_timer(inputTimeout).timeout
	#$CollisionShape2D.set_deferred("disabled", false)
	$CollisionShape2D.disabled = false
	print($CollisionShape2D.disabled)
	bouncing = false
	
	
# Handle Collisions
func _on_body_entered(body):
	# if   body == House: hit_house.emit()
	# elif body == Car:   hit_car.emit()
	
	if body.name == "Dr_House":
		bounce()
	
	if body.is_in_group("House"):
		hit_house.emit()
		#bounce()
	elif body.is_in_group("Car"):
		hit_car.emit()
	#$CollisionShape2D.set_deferred("disabled", true)
	return
