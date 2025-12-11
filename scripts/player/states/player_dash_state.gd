extends PlayerState

class_name DashState
 
const DASH_TIME := 0.15
const DASH_SPEED := 1200.0

var dash_timer := 0.0
var direction := 1.0

func enter(_prev_state):
	player.animation.play("dash")
	player.has_dashed = true
	
	if Input.get_axis("Left", "Right") != 0:
		direction = Input.get_axis("Left", "Right")
		
	player.real_velocity.x = direction * DASH_SPEED
	player.real_velocity.y = 0
	
	dash_timer = DASH_TIME

func physics_update(delta):
	dash_timer -= delta
	player.real_velocity.x = direction * DASH_SPEED
	
	if dash_timer <= 0:
		player.real_velocity.x = direction * player.SPEED
		if not player.is_on_floor():
			player.change_state("fall")
		else:
			player.change_state("run" if abs(player.real_velocity.x) > 0 else "idle")
