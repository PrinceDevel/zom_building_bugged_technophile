extends State

@onready var player:Player = get_parent().get_parent()

func physics_update(_delta:float):
	var dir = Input.get_axis("left","right")
	
	player.velocity.x = 0
	player.move_and_slide()
	
	if dir!=0:
		state_machine.change_state("move")
	
	elif Input.is_action_just_pressed("jump") or not player.is_on_floor():
		state_machine.change_state("jump")
	
