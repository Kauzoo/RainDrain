extends Node # Change to wanted Node (character/player)

# Global Constants #
var X_INCREMENT = 180
var Y_INCREMENT = 320
var X_DIRECTION =   0
var Y_DIRECTION =   0
var SPEED       =   3
####################

# Methods #
func _process(delta): ## change to delta if perma movement
	# TODO: implement "smooth" snake movement
	if Input.is_action_just_pressed("ui_left")  and X_DIRECTION == 0:
		Y_DIRECTION =  0
		X_DIRECTION = -1
	if Input.is_action_just_pressed("ui_right") and X_DIRECTION == 0:
		Y_DIRECTION =  0
		X_DIRECTION =  1
	if Input.is_action_just_pressed("ui_up")    and Y_DIRECTION == 0:
		X_DIRECTION =  0
		Y_DIRECTION = -1
	if Input.is_action_just_pressed("ui_down")  and Y_DIRECTION == 0:
		X_DIRECTION =  0
		Y_DIRECTION =  1
	## For perma movement, uncomment the next line
	position += (SPEED * Vector2(X_DIRECTION * X_INCREMENT * delta, Y_DIRECTION * Y_INCREMENT * delta))
	#position += Vector2(X_DIRECTION * X_INCREMENT, Y_DIRECTION * Y_INCREMENT)
	#X_DIRECTION = 0
	#Y_DIRECTION = 0
	return
###########
