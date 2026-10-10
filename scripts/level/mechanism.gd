extends Node2D

@onready var bg: TextureRect = $BG
@onready var zone: TextureRect = $zone
@onready var needle: Sprite2D = $Path2D/PathFollow2D/needle
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var path_follower: PathFollow2D = $Path2D/PathFollow2D

var level_number:int = 1

var zone_size:int = 10
var needle_speed:int = 60
var progress_rate:int = 10
var progress_decay_rate:int = 2
var punish:int = 2
var progress = 0

var active = false

func setup():
	level_number = EventBus.level_number
	zone.size.x = zone_size
	zone.position.x = bg.position.x

func _ready() -> void:
	setup()

func _physics_process(delta: float) -> void:
	active = visible
	progress = max(0,progress)
	progress = min(100,progress)
	progress -= progress_decay_rate*delta
	progress_bar.value = progress
	
	
	path_follower.progress+=needle_speed*delta
	
	if Input.is_action_just_pressed("mouse_left") and active:
		attempt()
	
	if progress>=100:
		progress_bar.value = 100
		EventBus.emit_signal("challenge_complete")
		reset()


func attempt():
	var needle_x = needle.global_position.x
	var left_x = zone.global_position.x 
	var right_x = zone.global_position.x + zone.size.x
	
	if needle_x>=left_x and needle_x<=right_x:
		success()
	else:
		failure()

func success():
	progress+=progress_rate
	shuffle()

func failure():
	progress-=punish

func shuffle():
	var new_x = randf()*(bg.size.x-zone.size.x)
	zone.position.x = bg.position.x + new_x

func reset():
	progress = 0
	progress_bar.value = 0
	setup()
