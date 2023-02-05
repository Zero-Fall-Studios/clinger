extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -40.0
@export var gravity: float = 20.0

@onready var ray = $RayCast2D
@onready var rope = $Rope
@onready var sprite = $Sprite2D

var thingtostick = null
var target_position = Vector2()
@export var spring_constant = 1.0
@export var damping_factor = 1.0
@export var max_distance = 10.0

enum direction_state { Left, Right }

var current_direction_state = direction_state.Right

func _process(delta):
	handle_grapple(delta)
	
func _physics_process(delta):
	handle_vertical_movement(delta)
	handle_horizontal_movement()
	move_and_slide()
		
func handle_vertical_movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		
func handle_horizontal_movement():
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		if velocity.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
func handle_grapple(delta):
	if Input.is_action_pressed("ui_left_click"):
		ray.look_at(get_global_mouse_position())
		
		if ray.is_colliding():
			thingtostick = ray.get_collider()
			if thingtostick:
				rope.visible = true
				target_position = to_local(ray.get_collision_point())
				rope.end_pos = target_position
				_calculate_spring(delta)
#				_calculate_swing_velocity()
		else:
			thingtostick = null 
			
	if not Input.is_action_pressed("ui_left_click"):
		rope.visible = false
		thingtostick = null          
		
func _calculate_spring(delta):
	# Calculate the displacement between the current position and the target position
	var displacement = target_position - position

	# Calculate the spring force using Hooke's law
	var spring_force = spring_constant * displacement

	# Calculate the damping force
	var damping_force = -damping_factor * velocity

	# Calculate the total force
	var total_force = spring_force + damping_force

	velocity = velocity + total_force
	
func _calculate_swing_velocity():
	var rope_length = rope.start_pos.distance_to(rope.end_pos)
	var character_position = get_global_position()
	var distance_to_anchor = rope.get_global_position().distance_to(character_position)
	var acceleration = gravity
	var total_force = sqrt(2 * acceleration * (rope_length - distance_to_anchor))
	
	velocity.x = velocity.x + total_force
	velocity.y = velocity.y + total_force
