extends PlayerState

class_name IdleState

func enter(_prev_state):
	player.real_velocity.x = 0.0
	player.has_dashed = false
	if player.animation.animation != "idle":
		player.animation.play("idle")

func handle_input(_event):
	if player.disable_inputs or not player.is_alive:
		return
		
	if Input.is_action_just_pressed("Sleep") and player.is_on_floor():
		player.change_state("sleep")
		return
	
	var direction := Input.get_axis("Left", "Right")
	
	if Input.is_action_just_pressed("ui_accept") and player.is_on_floor():
		player.change_state("jump")
		return
		
	if Input.is_action_just_pressed("Dash") and direction != 0.0 and not player.has_dashed:
		player.change_state("dash")
		return
		
	if direction != 0.0:
		player.change_state("run")

func physics_update(delta):
	# airborne transitions
	if not player.is_on_floor() and player.velocity.y < 0:
		player.change_state("jump")
		return
	if not player.is_on_floor() and player.velocity.y > 0:
		player.change_state("fall")
		return
