extends Area2D

signal hit_house
signal hit_car

@export var WALKING_SPEED = 360
@export var STARTING_POS  = Vector2(0, 0)
@export var JACKHAMMER_SPEED_MULT = 0.7

var direction = Vector2.ZERO
var jackhammer_on = false
var velocity = Vector2.ZERO # The player's movement vector.
var old_pos = Vector2.ZERO

# bounce stuff
var bouncing = false
var inputTimeout = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

func check_input():
	jackhammer_on = Input.is_action_pressed("jackhammer")
	if(bouncing):
		return
	var new_direction = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		new_direction += Vector2(1, 0)
	if Input.is_action_pressed("move_left"):
		new_direction += Vector2(-1, 0)
	if Input.is_action_pressed("move_down"):
		new_direction += Vector2(0, 1)
	if Input.is_action_pressed("move_up"):
		new_direction += Vector2(0, -1)

	if new_direction != Vector2.ZERO:
		direction = new_direction.normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	old_pos = position
	velocity = Vector2.ZERO # The player's movement vector.
	check_input()

	velocity = WALKING_SPEED * direction * (JACKHAMMER_SPEED_MULT if jackhammer_on else 1)
	position += velocity * delta

	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

	$AnimatedSprite2D.animation = "jackhammer" if jackhammer_on else "idle"

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
