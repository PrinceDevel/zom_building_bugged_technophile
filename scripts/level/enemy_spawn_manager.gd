extends Node

@onready var spawn_timer: Timer = $spawn_timer
@onready var wave_timer: Timer = $wave_timer
@onready var wave_cooldown: Timer = $wave_cooldown
@onready var enemis: Node2D = $enemies

var _1 = preload("res://scenes/enemy_1.tscn")
var _2 = preload("res://scenes/enemy_2.tscn")
var _3 = preload("res://scenes/enemy_3.tscn")

var wave_cooldown_time  = 10
var wave_interval_time = 5

var enemy_list = [_1,_1,_1,_2,_3,_2,_3,_2,_3,_2,_2,_2,_2,_3,_3]
var spawn_rates =[10,10,10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 100]

var difficulty:int = 1

var spawn_interval:float = 2

var spawn_nodes
var rates
var enemies


func spawn():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var index = rng.rand_weighted(rates)
	var chosen = enemies[index]
	var spawn_loaction = spawn_nodes[randi_range(0,len(spawn_nodes)-1)].global_position
	var enemy = chosen.instantiate()
	enemis.add_child(enemy)
	enemy.global_position = spawn_loaction


func change_difficulty(new_diff):
	spawn_nodes = get_parent().enemy_spawn_nodes
	difficulty = new_diff
	rates = spawn_rates.slice(0,min(difficulty,len(spawn_rates)-1))
	enemies = enemy_list.slice(0,min(difficulty,len(spawn_rates)-1))
	spawn_interval = 0.3+0.7/difficulty
	spawn_timer.wait_time = spawn_interval

func _on_spawn_timer_timeout() -> void:
	spawn()

func _on_wave_timer_timeout() -> void:
	change_difficulty(1)
	wave_cooldown.wait_time = wave_cooldown_time
	wave_cooldown.start()

func _on_wave_cooldown_timeout() -> void:
	change_difficulty(EventBus.level_number)
	wave_timer.wait_time = wave_interval_time
	wave_timer.start()
	spawn_timer.start()
