extends CharacterBody2D

@export var walk_speed: float = 120.0
@export var sprint_speed: float = 180.0
@export var walk_fps: float = 6.0
@export var sprint_fps: float = 8.0

@onready var sprite = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	# 1. Get input vector (-1 to 1 for X and Y axes)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 2. Prevent diagonal movement by prioritizing the stronger input axis
	if direction != Vector2.ZERO:
		if abs(direction.x) >= abs(direction.y):
			direction = Vector2(sign(direction.x), 0)
		else:
			direction = Vector2(0, sign(direction.y))
			
	# 3. Check if the player is sprinting
	var is_sprinting: bool = Input.is_action_pressed("sprint")
	
	# 4. Determine current speed and animation speed scale
	var current_speed: float = walk_speed
	if is_sprinting:
		current_speed = sprint_speed
		sprite.speed_scale = sprint_fps / walk_fps
	else:
		sprite.speed_scale = 1.0

	# 5. Apply movement velocity
	if direction != Vector2.ZERO:
		velocity = direction * current_speed
		play_walk_animation(direction)
	else:
		velocity = Vector2.ZERO
		# Instead of stopping instantly, only stop if the animation has progressed 
		# past a tiny fraction of a second, OR force it to its idle frame.
		if sprite.is_playing() and sprite.frame == 0:
			# Let the first frame finish playing slightly so the tap register visually
			await get_tree().create_timer(0.05).timeout
			if velocity == Vector2.ZERO:
				sprite.stop()
		else:
			sprite.stop()
		
	# 6. Move the character
	move_and_slide()

# Chooses and plays the correct walking animation based on movement
func play_walk_animation(dir: Vector2) -> void:
	if dir.x > 0:
		sprite.play("walk_right")
	elif dir.x < 0:
		sprite.play("walk_left")
	elif dir.y > 0:
		sprite.play("walk_down")
	elif dir.y < 0:
		sprite.play("walk_up")
