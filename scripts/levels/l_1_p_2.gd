extends Node2D

var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_node("Player")
	player.disable_inputs_until_landed()
	
	var body_list = Global.get_bodies_by_scene(get_tree().current_scene.name)
	for body_data in body_list:
		var corpse = Global.create_body_with_values(body_data.coordinates, body_data.type, body_data.sprite, body_data.flipped)
		get_tree().current_scene.add_child(corpse)
	var sleep_list = Global.get_sleeping_bodies_by_scene(get_tree().current_scene.name)
	for sleep_data in sleep_list:
		var corpse = Global.create_sleeping_body(sleep_data.coordinates, sleep_data.flipped)
		get_tree().current_scene.add_child(corpse)
		
	Global.move_and_spawn_player(player)

func _on_player_has_died(corpse) -> void:
	Global.add_body(get_tree().current_scene.name, corpse)
	get_tree().current_scene.call_deferred("add_child", corpse)
