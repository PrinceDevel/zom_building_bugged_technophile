extends Area2D

var player:Player

@onready var image: Sprite2D = $Sprite2D

var blood = preload("res://scenes/blood.tscn")

var speed = 7
var dir
var dmg = 10

func _ready() -> void:
	player = EventBus.player
	

func _physics_process(_delta: float) -> void:
	position += speed*dir

func set_properties(data:weapon_data):
	speed = data.bullet_speed
	dmg = data.bullet_dmg
	image.texture = data.bullet_sprite

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(dmg)
		var blood = blood.instantiate()
		get_parent().add_child(blood)
		blood.global_position = global_position
	else:
		queue_free()
