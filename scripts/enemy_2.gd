extends CharacterBody2D

var player:Player
@onready var attack_cooldown: Timer = $attack_cooldown
@onready var node_2d: Node2D = $Node2D
@onready var sprite: AnimatedSprite2D = $Node2D/AnimatedSprite2D

var audio_player = preload("res://scenes/zombie_audio.tscn")

var player_in_range = false

var speed = 20
var gravity = 20

var health = 60
var dmg = 5
var atk_speed = 0.8

var drop_chance = 0.8

func _ready() -> void:
	player = EventBus.player
	attack_cooldown.wait_time= atk_speed
	
	var audio = audio_player.instantiate()
	add_child(audio)
	audio.spawn()

func _physics_process(_delta: float) -> void:
	var vec = (player.global_position-global_position)
	var dir_x = vec.normalized().x
	var dist = vec.length()
	
	if player.position.x > position.x: node_2d.scale.x = 1
	elif player.position.x < position.x: node_2d.scale.x = -1
	
	if dist>=15:velocity.x = speed*dir_x
	else:
		velocity.x = 0
		if not sprite.is_playing(): sprite.play("idle")
	
	if not sprite.is_playing():
		if abs(velocity.x)>0:sprite.play('walk')
	
	if not is_on_floor():
		velocity.y += gravity
	move_and_slide()
	
	if player_in_range and attack_cooldown.time_left==0:
		attack()

func take_damage(damage):
	health-=damage
	sprite.animation = "hurt"
	var dir = 0
	if player.global_position.x>global_position.x: dir = -1
	else: dir = 1
	flash_hit()
	position.x += dir*2
	if health<=0: die()

func die():
	if randf()<=drop_chance:
		EventBus.drop_loot(global_position)
	queue_free()

func attack():
	sprite.play("attack")
	player.take_damage(dmg)
	attack_cooldown.start()

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func flash_hit() -> void:
	sprite.self_modulate = Color(4, 0.3, 0.3, 1)
	await get_tree().create_timer(0.06).timeout
	sprite.self_modulate = Color.WHITE
