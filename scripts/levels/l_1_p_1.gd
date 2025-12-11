extends Node2D

var player: CharacterBody2D

func _ready() -> void:
	player = get_node("Player")
	player.set_locked_camera(0, -50, false, true)
	
	if Global.has_died_once:
		var exit = get_node("L1P1_Exit") as Transition
		var target = "res://scenes/levels/l1_p1_open_door_again_cutscene.tscn"
		exit.target = target
		exit.targetScene = load(target)

	var body_list = Global.get_bodies_by_scene(get_tree().current_scene.name)
	for body_data in body_list:
		var corpse = Global.create_body_with_values(body_data.coordinates, body_data.type, body_data.sprite, body_data.flipped)
		get_tree().current_scene.add_child(corpse)
	var sleep_list = Global.get_sleeping_bodies_by_scene(get_tree().current_scene.name)
	for sleep_data in sleep_list:
		var corpse = Global.create_sleeping_body(sleep_data.coordinates, sleep_data.flipped)
		get_tree().current_scene.add_child(corpse)
