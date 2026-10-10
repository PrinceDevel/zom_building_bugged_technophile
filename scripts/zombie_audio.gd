extends Node2D

@export var zombie_audios:Array[AudioStream]

@onready var zombie_audio_player: AudioStreamPlayer2D = $zombie_audio_player
@onready var spawn_audio_player: AudioStreamPlayer2D = $spawn_audio_player
@onready var cooldown: Timer = $cooldown

func spawn():
	spawn_audio_player.play()
	pass

func _on_cooldown_timeout() -> void:
	cooldown.wait_time = randf_range(5,10)
	var index = randi_range(0,len(zombie_audios)-1)
	zombie_audio_player.stream = zombie_audios[index]
	zombie_audio_player.play()
