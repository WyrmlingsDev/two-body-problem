extends PlayerState

class_name SleepState

var threshold := 0.2
var timer := 0.0
var is_selecting := false
var selection_index := 0
var selection_camera
var bodies

func enter(_prev_state: PlayerState) -> void:
	bodies = Global.get_sleeping_bodies_by_scene(get_tree().current_scene.name)
	timer = 0.0
	selection_index = 0
	player.animation.offset.y = -7
	player.animation.play("sleep")
	
	selection_camera = Camera2D.new()
	get_tree().current_scene.add_child(selection_camera)
	player.camera.enabled = false
	selection_camera.enabled = true
	selection_camera.position = player.position

func exit(_next_state: PlayerState) -> void:
	player.animation.offset.y = 0
	is_selecting = false
	player.camera.enabled = true
	selection_camera.enabled = false
	get_tree().current_scene.remove_child(selection_camera)
	selection_camera.queue_free()
	selection_camera = null

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_text_backspace") and not player.animation.is_playing():
		player.is_alive = false
		var offset := (64 - 18) * 0.5
		var sleeping_robot: Node = Global.create_sleeping_body(player.position + Vector2(0, offset), player.animation.flip_h)
		Global.add_sleeping_body(get_tree().current_scene.name, sleeping_robot)
		get_tree().current_scene.call_deferred("add_child", sleeping_robot)
		player.change_state("revive")
		return
	
	var direction := Input.get_axis("Left", "Right")
	
	if direction != 0.0 and not is_selecting:
		player.animation.play("awake")
		await player.animation.animation_finished
		player.change_state("run")

func physics_update(delta: float) -> void:
	if Input.is_action_pressed("Tab"):
		timer += delta
	
	if timer >= threshold and not is_selecting:
		is_selecting = true
		
	elif timer >= threshold and is_selecting:
		if bodies.size() == 0:
			return
			
		if Input.is_action_just_pressed("Right"):
			selection_index = (selection_index + 1) % bodies.size()
		elif Input.is_action_just_pressed("Left"):
			selection_index = (selection_index - 1) % 2
		
		var target_body = bodies[selection_index % bodies.size()]
		selection_camera.position = target_body["coordinates"]
		
	if Input.is_action_just_released("Tab"):
		is_selecting = false
		
		if bodies.size() == 0:
			player.animation.play("awake")
			await player.animation.animation_finished
			player.change_state("run")
			return
			
		if timer < threshold:
			selection_index = bodies.size() - 1
		
		var target_body = bodies[selection_index % bodies.size()]
		selection_camera.position = target_body["coordinates"]
		
		var offset := (64 - 18) * 0.5
		var sleeping_robot: Node = Global.create_sleeping_body(player.position + Vector2(0, offset), player.animation.flip_h)
		Global.add_sleeping_body(get_tree().current_scene.name, sleeping_robot)
		get_tree().current_scene.call_deferred("add_child", sleeping_robot)
		var find_body = get_tree().current_scene.get_node_or_null(str(target_body["name"]))
		Global.remove_sleeping_body(get_tree().current_scene.name, find_body)
		find_body.queue_free()
		player.position = target_body["coordinates"]
		player.animation.play("awake")
		await player.animation.animation_finished
		player.change_state("run")
