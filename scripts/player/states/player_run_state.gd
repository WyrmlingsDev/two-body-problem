extends PlayerState

class_name RunState

func enter(_prev_state):
	player.animation.offset.y = -8
	player.has_dashed = false
	if absf(player.real_velocity.x) <= 0.001:
		player.run_transition_counter = 0.07
		player.animation.play("run_start")
		
func exit(_next_state: PlayerState):
	player.animation.offset.y = 0
	
func handle_input(_event):
	if player.disable_inputs or not player.is_alive:
		return
		
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.change_state("jump")
		
	if Input.is_action_just_pressed("Dash") and not player.has_dashed:
		player.change_state("dash")

func physics_update(delta):
	var direction := 0.0
	if player.is_alive and not player.disable_inputs:
		direction = Input.get_axis("Left", "Right")
		
	# Horizontal motion
	if direction != 0.0:
		player.real_velocity.x = direction * player.SPEED
		player.animation.flip_h = direction < 0.0
	else:
		player.change_state("idle")
		return
		
	# Transition timer
	if player.run_transition_counter > 0.0:
		player.run_transition_counter -= delta
		if player.animation.animation != "run_start":
			player.animation.play("run_start")
	else:
		if player.animation.animation != "run":
			player.animation.play("run")

	# Airborne check
	if not player.is_on_floor():
		player.change_state("jump")
