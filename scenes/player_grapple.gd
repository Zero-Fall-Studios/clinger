extends CharacterBody2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer

@export var JUMP_FORCE = 300			# Force applied on jumping
@export var MOVE_SPEED = 50			# Speed to walk with
@export var RUN_SPEED = 100			# Speed to walk with
@export var GRAVITY = 10				# Gravity applied every second
@export var MAX_SPEED = 2000			# Maximum speed the player is allowed to move
@export var FRICTION_AIR = 0.95		# The friction while airborne
@export var FRICTION_GROUND = 0.85	# The friction while on the ground
@export var CHAIN_PULL = 15

var chain_velocity := Vector2(0,0)
var can_jump = false			# Whether the player used their air-jump
var is_idle = false
var is_walking = false
var is_running = false
var is_falling = false
var is_jumping = false
var is_swinging = false
var is_grounded = false
var is_landed = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# We clicked the mouse -> shoot()
			$Chain.shoot(get_local_mouse_position())
		else:
			# We released the mouse -> release()
			$Chain.release()

# This function is called every physics frame
func _physics_process(_delta: float) -> void:
	# Walking
	var speed = RUN_SPEED if is_running else MOVE_SPEED
	var walk = (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * speed

	# Falling
	velocity.y += GRAVITY

	# Hook physics
	if $Chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			chain_velocity.x *= 0.7
		is_swinging = true
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
		is_swinging = false
		
	velocity += chain_velocity

	velocity.x += walk		# apply the walking
	
	_handle_flip()
	
	move_and_slide()	# Actually apply all the forces
	
	velocity.x -= walk		# take away the walk speed again
	# ^ This is done so we don't build up walk speed over time

	# Manage friction and refresh jump and stuff
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	
	is_grounded = is_on_floor()
	if is_grounded:
		
		if is_falling:
			is_landed = true

		is_jumping = false
		is_falling = false
		velocity.x *= FRICTION_GROUND	# Apply friction only on x (we are not moving on y anyway)
		can_jump = true 				# We refresh our air-jump
		if velocity.y >= 5:		# Keep the y-velocity small such that
			velocity.y = 5		# gravity doesn't make this number huge
		if walk == 0:
			is_idle = true
			is_running = false
			is_walking = false
		elif Input.is_action_pressed("run"):
			is_idle = false
			is_running = true
			is_walking = false
		else:
			is_idle = false
			is_running = false
			is_walking = true
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5

	# Apply air friction
	if !is_grounded:
		velocity.x *= FRICTION_AIR
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR

	if velocity.y > 0:
		is_jumping = false
		is_falling = true

	# Jumping
	if Input.is_action_just_pressed("jump"):
		if is_grounded:
			velocity.y = -JUMP_FORCE	# Apply the jump-force
			is_jumping = true
			if is_running:
				animation_player.play("Flip")
			else:
				animation_player.play("Jump")
		elif can_jump:
			can_jump = false	# Used air-jump
			velocity.y = -JUMP_FORCE
			is_jumping = true
			if is_running:
				animation_player.play("Flip")
			else:
				animation_player.play("Jump")
			
	_update_animations()
			
func _handle_flip():
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
			
func _update_animations():
	if is_jumping:
		return
		
	if is_falling:
		animation_player.play("Fall")
		return
		
	if is_landed:
		animation_player.play("Land")
		await get_tree().create_timer(.2).timeout
		is_landed = false
		return
		
	if is_walking:
		animation_player.play("Walk")
	elif is_running:
		animation_player.play("Run")	
	elif is_idle:
		animation_player.play("Idle")
	
	
