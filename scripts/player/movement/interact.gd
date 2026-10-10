extends State

@onready var player:Player = get_parent().get_parent()

var gravity = 20
var speed = 100

func enter():
	player.velocity.x = 0


func physics_update(_delta:float):
	if not player.is_on_floor():
		player.velocity.y+=gravity
	
	var dir = Input.get_axis("left","right")
	player.velocity.x = dir*speed
	player.move_and_slide()
	
	if Input.is_action_just_pressed("e"):
		state_machine.change_state("idle")
