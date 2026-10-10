extends Node

signal challenge_complete(bool)
signal player_died()

var level
var player
var camera
var level_number:int = 1
var player_interacting = false

var respawn_point = Vector2(500,625)

var start_info = [100,20]


## items _______

var AR: item_data = preload("res://others/items/AR.tres")
var AR_bullet: item_data = preload("res://others/items/AR_bullets.tres")
var pistol: item_data = preload("res://others/items/pistol.tres")
var pistol_bullet: item_data = preload("res://others/items/pistol_bullets.tres")
var shotgun: item_data = preload("res://others/items/shotgun.tres")
var shotgun_bullet: item_data = preload("res://others/items/shotgun_bullets.tres")
var healthKit: item_data = preload("res://others/items/healthKit.tres")
var instant_health: item_data = preload("res://others/items/instant_health.tres")
var items = [AR,AR_bullet,pistol,pistol_bullet,shotgun,shotgun_bullet,healthKit,instant_health]

var weights = [10,40,15,60,10,40,40,40]
var item_scene = preload("res://scenes/item.tscn")


func drop_loot(pos:Vector2):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var index = rng.rand_weighted(weights)
	var chosen = items[index]
	
	var item = item_scene.instantiate()
	level.add_child.call_deferred(item)
	item.global_position = pos
	item.setup(chosen)
