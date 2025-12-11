extends PlayerState

class_name JumpState

var direction := 0.0

func enter(_prev_state):
	if player.animation.animation != "jump":
		player.animation.play("jump")
	
	if player.is_alive and not player.disable_inputs:
		if player.is_on_floor():
			player.real_velocity.y = player.JUMP_VELOCITY
			player.is_holding_jump_key = true
		# alters the jump state a bit to accomodate
		# an arc automatically off a wall jump
		elif _prev_state is WallGrabState:
			player.animation.flip_h = -sign(_prev_state.wall_direction)
			player.real_velocity.y = player.WALL_JUMP_VELOCITY
			player.real_velocity.x = -_prev_state.wall_direction * player.SPEED
			player.is_holding_jump_key = true
	
	player.has_jumped = true

func handle_input(_event):
	if not Input.is_action_pressed("ui_accept"):
		player.is_holding_jump_key = false
		
	if Input.is_action_just_pressed("Dash") and direction != 0.0 and not player.has_dashed:
		player.change_state("dash")
		return

func physics_update(delta):
	player.real_velocity += player.get_gravity() * 1.1 * delta
	player.real_velocity.x = 0.0
	
	# horizontal air control
	if player.is_alive and not player.disable_inputs:
		direction = Input.get_axis("Left", "Right")
	if direction != 0.0:
		player.real_velocity.x = direction * player.SPEED
		player.animation.flip_h = player.real_velocity.x < 0.0
		
	# jump to wall grab
	# must be facing and going toward a grabbable object to hook on
	for i in range(player.get_slide_collision_count()):
		var collision = player.get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		var pushing_toward_wall = (normal.x > 0 and direction < 0) or (normal.x < 0 and direction > 0)
		if pushing_toward_wall and player.real_velocity.y > 0 and abs(normal.y) < 0.5:
			var wall_grab_state = player.states["wall_grab"]
			wall_grab_state.wall_direction = sign(direction)
			player.change_state("wall_grab")
			return
				
	if not player.is_holding_jump_key and player.velocity.y < 0.0:
		player.real_velocity.y += player.FALL_TIGHTNESS
	
	# transition to fall when velocity flips
	if player.real_velocity.y > 0.0 and not player.is_on_floor():
		player.change_state("fall")
		
	if player.is_on_floor():
		player.has_jumped = false
		if direction != 0.0:
			player.change_state("run")
		else:
			player.change_state("idle")
