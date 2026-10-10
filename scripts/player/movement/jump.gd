extends State

@onready var player:Player = get_parent().get_parent()

var speed = 200
var jump = 300
var gravity = 20

func enter():
	if player.is_on_floor():
		player.velocity.y = -jump

func physics_update(_delta:float):
	var dir = Input.get_axis("left","right")
	
	player.velocity.x = dir*speed
	
	player.velocity.y+=gravity
	player.move_and_slide()
	
	if player.is_on_floor() and player.velocity.y>=0:
		state_machine.change_state("idle")
