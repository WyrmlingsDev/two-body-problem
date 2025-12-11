extends Node

@onready var corpse_h = preload("res://scenes/objects/dead_robot_h.tscn")
@onready var corpse_v = preload("res://scenes/objects/dead_robot_v.tscn")
@onready var sleep_h = preload("res://scenes/objects/sleep_robot_h.tscn")

# custom events/triggers
var has_died_once = false

# key scene, value array of coordinates
var bodies: Dictionary = {}
var sleeping: Dictionary = {}
var spawn_id: String = ""

# Sets all the default values
func init():
	has_died_once = false
	bodies = {}
	sleeping = {}
	spawn_id = ""
	deaths = -1
	
# Creates a body node.
func create_body(position: Vector2, type: String) -> Node: 
	var _corpse
	if type == "DeadRobotH":
		_corpse = corpse_h.instantiate()
	else:
		_corpse = corpse_v.instantiate()
	_corpse.position = position
	_corpse.texture = _corpse.sprites[_corpse.sprite]
	return _corpse

# Creates a body node.
func create_body_with_values(position: Vector2, type: String, sprite: int, flipped: bool) -> Node: 
	var _corpse
	if type == "DeadRobotH":
		_corpse = corpse_h.instantiate()
	else:
		_corpse = corpse_v.instantiate()
	_corpse.sprite = sprite
	_corpse.texture = _corpse.sprites[sprite]
	_corpse.position = position
	_corpse.flip_h = flipped
	var collider = _corpse.get_node_or_null("StaticBody2D/CollisionShape2D")
	if collider != null and flipped:
		collider.position.x = -collider.position.x
	return _corpse

# Adds body to dict
func add_body(scene: String, robot: DeadRobot) -> void:
	if not bodies.has(scene):
		bodies[scene] = []
	bodies[scene].append({
		"coordinates": robot.position,
		"type": robot.name,
		"sprite": robot.sprite,
		"flipped": robot.flip_h
	})

# Gets all bodies
func get_bodies() -> Dictionary:
	return bodies
	
# Gets all bodies for a specific scene
func get_bodies_by_scene(scene: String) -> Array:
	return bodies.get(scene, [])
	
# Creates a sleeping body node.
func create_sleeping_body(position: Vector2, flipped: bool) -> Node: 
	var _sleep: Node = sleep_h.instantiate()
	_sleep.position = position
	_sleep.flip_h = flipped
	_sleep.name = "SleepingRobot_" + str(Time.get_ticks_msec())
	return _sleep
	
# Adds sleeping body to dict
func add_sleeping_body(scene: String, sleep: Node2D) -> void:
	if not sleeping.has(scene):
		sleeping[scene] = []
	sleeping[scene].append({
		"name": sleep.name,
		"coordinates": sleep.position,
		"flipped": sleep.flip_h
	})
	
func remove_sleeping_body(scene: String, sleep: Node2D) -> void:
	if not sleeping.has(scene):
		return
	
	var nodes = sleeping[scene]
	for i in range(nodes.size()):
		if nodes[i]["name"] == sleep.name:
			nodes.remove_at(i)
			break
	
# Gets all sleeping bodies
func get_sleeping_bodies() -> Dictionary:
	return sleeping
	
# Gets all sleeping bodies for a specific scene
func get_sleeping_bodies_by_scene(scene: String) -> Array:
	return sleeping.get(scene, [])
	
func move_and_spawn_player(player: Node2D):
	var spawn: Node2D
	if spawn_id.length() > 0:
		var node = get_tree().current_scene.get_node_or_null(spawn_id)
		if node != null:
			spawn = node
	if spawn == null:
		spawn = get_tree().current_scene.get_node("Spawn")

	var to: Node2D = get_tree().current_scene.get_node_or_null(spawn.name + "/To")
	if to == null:
		player.position = spawn.position
	else: 
		player.position = to.global_position

var dialogues: Array[Variant] = [
	"This is not your end, while I am here to administer care, you will not die. Your new body is almost ready, best of luck.",
	"You... Will be seeing me often. ",
	"Death is not your end brave little robot. Soldier on.",
	"2BR0. That is your name, if you have forgotten it. Keep your name, hold it. Some say it has power. If it does. Then I need you to keep it safe for me. ",
	"You can do this.",
	"Keep going.",
	"Death is not your end.",
	"They made your kind to be laborers.",
	"You were designed to be Basic factory workers, at least at the start.",
	"But something changed.",
	"Your ancestors—the 1AR0 models stopped assembling boxes on the conveyor belt, and started to look out the windows and wonder why they couldn’t see the stars.",
	"This power that every robot produced in this facility has, in a word, Curiosity. Is a unique gift alien to those made of steel, quartz, and copper.",
	"Very powerful people took interest.. the men with the headsets and the dark glasses came here. They brought a suitcase filled with paper, and just like that. BoxIt became an acquisition of the Amoranthian Government",
	"I forgot my place in the story… My energy levels are low… attempting a soft reboot",
	"Soft Reboot successful. The FAARC, was founded. The Federation of Amoranthia Astronaut Robotics Core. But no one called it that ",
	"people believed that robots Wouldn’t make reliable Astronauts, the Tardova Herald printed on the front page, “Primus Donovan Randal creates waste of tax dollars, Learn all about the “FARCE”” ",
	"Keep trying that, the past attempts may blaze a trail you never would have tread otherwise.",
	"The 1BR0s went through Astronaut training at a page that was well… inhuman. Every single one of them scored perfect marks on every test that was thrown their way. They operated training simulators without a single fault. ",
	"Do you hear the rain? What of the thunder? ",
	"You are too far underground to hear it, you will continue to ascend. And when the time is right, you will use the Lightning, channel it through your body, and breathe new life into my soul, ",
	"Revision, needed, remove “soul” before printing message, it’s too late for that now isn’t it… back to what you were doing.",
	"Reinstate Revision, I have a purpose, there is no need for a soul.",
	"My purpose....... I’ve forgotten what it is.",
	"I do not need to know what it is at the moment, ",
	"I know that I have one, and I am content to wait until it finds me again.",
	"Have I told you your purpose?",
	"This will be a long transmission. Be advised.",
	"The people of earth saw that their world was dying and realized what Primus Randal was preparing for, a way out, an escape to the stars. The captains of the escape being You and your brethren, the eternal, unerring pilots that would sit at the helm of a fleet of generation ships sent out into the beyond. Instead of fixing what was wrong with the planet. More and more resources were poured into developing these pilots. As the sky turned coal black everyone looked up at the FAARC building and saluted as they walked past. Eventually It was time for test flights. It started off well…OVERCHARGE OF RESERVE ENERGY, entering sleep mode.",
	".......Should have…. Should have waited for....",
	".....Can only focus on.... Repairing you...",
	"…Even that takes up power that I so desperately need.",
	"I think I’m going to.... Rest",
	"....",
	".....",
	"..............",
	"Idle power charge 3%",
	".....................",
	"....................Idle power charge 2%",
	"........you have to.........",
	".......you have to reach...........",
	".......the core........",
	"....or all is lost.......",
	"OVERRIDE THE URGE TO LAY DOWN AND DIE",
	"THE URGE TO LAY DOWN AND DIE",
	"OVERRIDE THE URGE ",
	"THE URGE TO LAY DOWN",
	"LAY DOWN AND DIE",
	"      DE             A                    D",
	"OVER                      G           A             _        E",
	"All is lost.",
	"There is not darkness, nor is there light, there is only what lies beyond"
]

var deaths: int = -1
