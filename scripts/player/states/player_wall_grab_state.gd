extends PlayerState

class_name WallGrabState

var wall_direction: float = 0.0

func enter(_prev_state: PlayerState) -> void:
	player.real_velocity = Vector2.ZERO
	
	if player.animation.animation != "wall_grab":
		player.animation.play("wall_grab")	

func handle_input(_event: InputEvent) -> void:
	player.real_velocity = Vector2.ZERO
	
	# cancel wall grab if a direction is pressed
	var direction := Input.get_axis("Left", "Right")
	if direction != 0.0 and sign(direction) != wall_direction:
		player.change_state("fall")

func physics_update(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		player.change_state("jump")
