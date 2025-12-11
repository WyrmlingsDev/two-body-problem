extends CharacterBody2D

class_name Player

var is_alive = true;

@export var debug = false

const SPEED = 380.0
const JUMP_VELOCITY = -650.0
const WALL_JUMP_VELOCITY = -550.0
const MAX_VELOCITY = 800
const FALL_TIGHTNESS = 20;

@onready var animation = $AnimatedSprite2D
@onready var death_audio = [
	preload("res://assets/audio/Random6 (1).wav"),
	preload("res://assets/audio/Random6 (2).wav"),
	preload("res://assets/audio/Random6.wav"),
]

var run_transition_counter = 0;
var has_jumped = false
var has_dashed = false
var is_holding_jump_key = false
var real_velocity = Vector2(0,0) #'actual' velocity before modifications are performed at the end
var disable_inputs = false #disable inputs without enabling respawn

# special event booleans
var disable_until_landed = false #used in 1st level
var death_anim_triggered = false #use to prevent death events from triggering more than once

var camera: Camera2D
var lock_camera_y = false
var lock_camera_x = false
var locked_camera_offsets := Vector2(0,0)

var current_state
var states = {}

signal has_died

var velocity_multipliers := [
	[-1000, -300, 1.4],
	[-300, 0, 0.8],
	[0, 100, 1.5],
	[100, 10000, 1.7]
]

func _ready() -> void:
	states = {
		"idle": preload("res://scripts/player/states/player_idle_state.gd").new(),
		"run": preload("res://scripts/player/states/player_run_state.gd").new(),
		"jump": preload("res://scripts/player/states/player_jump_state.gd").new(),
		"wall_grab": preload("res://scripts/player/states/player_wall_grab_state.gd").new(),
		"revive": preload("res://scripts/player/states/player_revive_state.gd").new(),
		"fall": preload("res://scripts/player/states/player_fall_state.gd").new(),
		"dead": preload("res://scripts/player/states/player_dead_state.gd").new(),
		"dash": preload("res://scripts/player/states/player_dash_state.gd").new(),
		"sleep": preload("res://scripts/player/states/player_sleep_state.gd").new()
	}

	for state in states.values():
		state.player = self
		add_child(state)
		
	change_state("idle")
	camera = self.get_node("Camera2D")
	camera.player = self
	
	await get_tree().process_frame
	for node in get_tree().get_nodes_in_group("Hazards"):
		node.player_died.connect(_on_player_died)

func change_state(state_name: String):
	if not states.has(state_name):
		push_warning("State '%s' not found" % state_name)
		return

	if current_state == states[state_name]:
		return

	if current_state:
		current_state.exit(states[state_name])

	var prev = current_state
	current_state = states[state_name]
	current_state.enter(prev)

func _physics_process(delta: float) -> void:
	if not current_state:
		return
	current_state.handle_input(null)
	current_state.physics_update(delta)
	
	apply_movement(delta)
	move_and_slide()
	
	# post-movement camera locks
	if lock_camera_y:
		camera.position.y = locked_camera_offsets.y - position.y
	if lock_camera_x:
		camera.position.x = locked_camera_offsets.x - position.x
		
	# landing gate used by scripted events
	if disable_until_landed and is_on_floor():
		disable_until_landed = false
		disable_inputs = false
		
func apply_movement(delta: float):
	if not is_on_floor():
		real_velocity += get_gravity() * delta
		
	velocity = real_velocity
	
	# Apply velocity multipliers to vertical motion
	velocity.x = real_velocity.x
	velocity.y = real_velocity.y
	for val in velocity_multipliers:
		if real_velocity.y >= val[0] and real_velocity.y < val[1]:
			velocity.y *= val[2]
			break

	velocity.y = clamp(velocity.y, -1.0 * MAX_VELOCITY, MAX_VELOCITY)

func set_locked_camera(x, y, enable_x: bool, enable_y: bool):
	lock_camera_x = enable_x
	lock_camera_y = enable_y
	locked_camera_offsets = Vector2(x,y)	

func disable_inputs_until_landed():
	disable_until_landed = true
	disable_inputs = true
	
func _on_node_added(node):
	if node is HazardArea2D:
		node.player_died.connect(_on_player_died)
		
func _on_player_died(_body, hazard: String):
	change_state("dead")
	
	# electricity hazards do not spawn bodies
	if hazard.to_lower().contains("electricity"):
		return
	
	var offset := (64 - 24) * 0.5
	var is_vertical := hazard.ends_with("_v")
	var corpse_type := "DeadRobotV" if hazard.ends_with("_v") else "DeadRobotH"
	
	var _corpse
	if is_vertical:
		_corpse = Global.create_body(position, corpse_type)
	else:
		# only apply the offset on horizontal bodies.
		_corpse = Global.create_body(position + Vector2(0, offset), corpse_type)
	
	# the corpse sprite/collider should match the flip of the player
	var flip = !animation.flip_h
	_corpse.flip_h = flip
	var collider = _corpse.get_node_or_null("StaticBody2D/CollisionShape2D")
	if collider != null and flip:
		collider.position.x = -collider.position.x
		
	has_died.emit(_corpse)
