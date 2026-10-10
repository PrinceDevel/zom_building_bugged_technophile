extends Area2D
class_name MAIN_LIFT

var player_in_range = false
var player_interacting = false

@onready var label: Label = $Label
@onready var mechanism: Node2D = $mechanism
var player:Player
var level = null

func _ready() -> void:
	player = EventBus.player
	player_interacting = false
	player_in_range = false

func _physics_process(_delta: float) -> void:
	EventBus.player_interacting = player_interacting
	label.visible = player_in_range and not player_interacting
	mechanism.visible = player_interacting
	
	if player_in_range and Input.is_action_just_pressed("e") and not player_interacting:
		player_interacting = true
		player.movements.change_state("interact")
	elif player_interacting and Input.is_action_just_pressed("e"):
		player_interacting = false
		player.movements.change_state("idle")
	if player_interacting and not player_in_range:
		player_interacting = false
		player.movements.change_state("idle")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		player_in_range = true
		
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		player_in_range = false

func reset():
	pass
