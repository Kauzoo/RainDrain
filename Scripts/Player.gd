extends CharacterBody2D

#signal hit_house
#signal hit_car

signal deal_damage

@export var WALKING_SPEED = 30_000
@export var STARTING_POS  = Vector2(0, 0)
@export var JH_SPEED_MULT = 0.5
@export var JH_LOCKOUT_TIMEOUT = 1.0
@export var JH_SLOWDOWN_TIME = 0.2 * 1000
@export var JH_SPEEDUP_TIME = 2.0 * 1000

var direction = Vector2.ZERO

var jh_on = false
var jh_last_switch = 0
var jh_locked = false

var jh_audio = preload("res://Audio/jackh2.mp3")

#var old_pos = Vector2.ZERO

# bounce stuff
#var bouncing = false
#var inputTimeout = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

	jh_last_switch = Time.get_ticks_msec()
	$AudioStreamPlayer.stream = jh_audio

func jh_unlock():
	await get_tree().create_timer(JH_LOCKOUT_TIMEOUT).timeout
	jh_locked = false

func check_input():
	#if bouncing:
	#	return
	

	var old_jh_on = jh_on
	var new_jh_on = Input.is_action_pressed("jackhammer")
	if not jh_locked and old_jh_on != new_jh_on:
		jh_on = new_jh_on
		jh_last_switch = Time.get_ticks_msec()
		if jh_on:
			$AudioStreamPlayer.play()
		else:
			$AudioStreamPlayer.stop()
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

	# if new_direction != Vector2.ZERO:
	direction = new_direction.normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# old_pos = position
	check_input()

	#position += velocity * delta

	if jh_on:
		deal_damage.emit(position, delta)

	#$Camera2D.set_zoom(velocity * Vector2(0.5, 0.5))
	#$Camera2D.zoom()

	if direction.x != 0:
		$AnimatedSprite2D.flip_h = direction.x < 0

	$AnimatedSprite2D.animation = ("jackhammer" if jh_on else "idle")

func _physics_process(delta):
	# var velocity # = Vector2.ZERO # The player's movement vector.
	var v_max = WALKING_SPEED * direction * delta
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
	self.move_and_slide()
	#var collision = self.move_and_collide(velocity)
	#if collision != null:
	#	print(collision)
	# print(delta)

"""
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
"""
