extends Area2D

signal hit_house
signal hit_car

@export var WALKING_SPEED = 360
@export var STARTING_POS  = Vector2(0, 0)
@export var JH_SPEED_MULT = 0.4
@export var JH_LOCKOUT_TIMEOUT = 0.5
@export var JH_SLOWDOWN_TIME = 0.2 * 1000
@export var JH_SPEEDUP_TIME = 0.5 * 1000

var direction = Vector2.ZERO

var jh_on = false
var jh_last_switch = 0
var jh_locked = false

var old_pos = Vector2.ZERO

# bounce stuff
var bouncing = false
var inputTimeout = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

	jh_last_switch = Time.get_ticks_msec()

func jh_unlock():
	await get_tree().create_timer(JH_LOCKOUT_TIMEOUT).timeout
	jh_locked = false

func check_input():
	if bouncing:
		return

	var old_jh_on = jh_on
	var new_jh_on = Input.is_action_pressed("jackhammer")
	if not jh_locked and old_jh_on != new_jh_on:
		jh_on = new_jh_on
		jh_last_switch = Time.get_ticks_msec()
	if not old_jh_on and new_jh_on and not jh_locked:
		jh_locked = true
		jh_unlock()

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

func lerp(a, b, t):
	return (1 - t) * a + t * b

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	old_pos = position
	var velocity = Vector2.ZERO # The player's movement vector.
	check_input()

	var v_max = WALKING_SPEED * direction
	var v_min = v_max * JH_SPEED_MULT
	var now = Time.get_ticks_msec()
	if jh_on:
		velocity = lerp(
			v_max, v_min,
			clamp(now - jh_last_switch, 0, JH_SLOWDOWN_TIME) / JH_SLOWDOWN_TIME
		)
	else:
		velocity = lerp(
			v_min, v_max,
			clamp(now - jh_last_switch, 0, JH_SPEEDUP_TIME) / JH_SPEEDUP_TIME
		)

	position += velocity * delta

	#$Camera2D.set_zoom(velocity * Vector2(0.5, 0.5))
	#$Camera2D.zoom()

	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0

	$AnimatedSprite2D.animation = ("jackhammer" if jh_on else "idle")

func bounce():
	jh_on = false
	try_wait()

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
