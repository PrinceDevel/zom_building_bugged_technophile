extends CPUParticles2D

@onready var timer: Timer = $Timer

func _ready() -> void:
	timer.wait_time = lifetime	
	timer.start()

func _on_timer_timeout() -> void:
	queue_free()
