extends State

@onready var player:Player = get_parent().get_parent()

var speed = 200

func physics_update(_delta:float):
	var dir = Input.get_axis("left","right")
	
	player.velocity.x = dir*speed
	player.move_and_slide()
	
	if Input.is_action_just_pressed("jump") or not player.is_on_floor():
		state_machine.change_state("jump")
	elif dir==0:
		state_machine.change_state("idle")
