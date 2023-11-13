extends CharacterBody2D

@export var speed = 0.0
@export var acceleration = 1000.0
@export var deceleration = 1200.0

var max_speed = 100000.0 # max_speed = velocity.length() * ~60
var max_speed_reverse = -30000.0

var max_turn_speed = 3.0
var turn_speed_left = 0.0
var turn_speed_right = 0.0
var turn_acceleration = .5
var turn_deceleration = .2

# Control the positive and negatives (the forward/back, left/right)
var move_direction = 0
var turn_direction = 0

func get_input(delta):
	move_direction = Input.get_axis("Decelerate", "Accelerate")
	turn_direction = Input.get_axis("Turn Left", "Turn Right")
	
	if speed < 0: turn_direction = -turn_direction
	
	# This is so we can't turn while stopped
	# velocity.length() handles forward and reverse
	if (velocity.length() <= 200.0):
		turn_direction = 0
	
	# While we haven't reached max speed and pushing forward, we add to the speed
	if move_direction == 1 && speed < max_speed:
		if (speed < 0): speed = approach_zero(speed, deceleration)
		speed += acceleration
		velocity = transform.x * (speed * delta)
	elif move_direction == -1 && speed > max_speed_reverse:
		if (speed > 0): speed = approach_zero(speed, deceleration)
		speed -= acceleration
		velocity = transform.x * (speed * delta)
	else:
		if (velocity.length() <= 10.0): # If we get close enough to zero, just stop the car
			velocity = Vector2.ZERO
		else:
			speed = approach_zero(speed, deceleration) # Slow down while not pressing on the gas
			velocity = transform.x * (speed * delta)
	
	if turn_direction == 0:
		if (turn_speed_right + turn_speed_left) < .3 && (turn_speed_right + turn_speed_left) > -.3: # If turn speed gets close to zero, just stop turning
			turn_speed_right = 0
			turn_speed_left = 0
		else:
			# Steering slowly "resets" when no input is provided
			turn_speed_right = approach_zero(turn_speed_right, turn_deceleration)
			turn_speed_left = approach_zero(turn_speed_left, turn_deceleration)
	elif (turn_direction == 1):
		if turn_speed_right < max_turn_speed:
			turn_speed_right += turn_acceleration
		turn_speed_left = approach_zero(turn_speed_left, turn_acceleration)
	elif (turn_direction == -1):
		if turn_speed_left > -max_turn_speed:
			turn_speed_left -= turn_acceleration
		turn_speed_right = approach_zero(turn_speed_right, turn_acceleration)
	rotation += (turn_speed_right + turn_speed_left) * delta
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	if move_and_slide(): speed = speed

func approach_zero(speed_, deceleration_):
	if speed_ > 0:
		speed_ -= deceleration_
	elif speed_ < 0:
		speed_ += deceleration_
	return speed_
