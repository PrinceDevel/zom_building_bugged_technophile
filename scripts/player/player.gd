extends CharacterBody2D
class_name Player

@onready var node: Node2D = $Node
@onready var sprite: AnimatedSprite2D = $Node/AnimatedSprite2D
@onready var level: Node2D = get_parent()
@onready var movements: StateMachine = $movements
@onready var hit_box: Area2D = $Node/hit_box
@onready var hurt_box: Area2D = $Node/hurt_box
@onready var fire_interval: Timer = $fire_interval
@onready var muzzle: Node2D = $"muzzle pivot/muzzle"
@onready var muzzle_pivot: Node2D = $"muzzle pivot"
@onready var reload_timer: Timer = $reload_timer
@onready var weapon_sprite: Sprite2D = $"muzzle pivot/muzzle/Sprite2D"
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var label_2: Label = $CanvasLayer/Label2
@onready var camera_2d: Camera2D = $Camera2D
@onready var gunshot_audio: AudioStreamPlayer2D = $gunshot_audio
@onready var reload_audio: AudioStreamPlayer2D = $reload_audio

@onready var label: Label = $CanvasLayer/Label


var bullet_scene = preload("res://scenes/bullet.tscn")


@export var current_weapon:weapon_data
var health = 100

var ammo_array = [0,0,0]
var mag_array = [0,0,0]
var weapon_ids = [0,0,0]
var weapon_resources = []
var healthKits = 0

var mag_size
var ammo_in_mag

var reloading:bool = false

func _ready() -> void:
	health = 100
	mag_size = current_weapon.mag_size
	ammo_in_mag = mag_size
	weapon_ids[current_weapon.weapon_id] = 1
	ammo_array[current_weapon.weapon_id] = mag_size*2
	mag_array[current_weapon.weapon_id] = mag_size
	EventBus.player = self
	EventBus.camera = camera_2d
	weapon_resources.append(current_weapon)
	equip_weapon(current_weapon)
	set_checkpoint()

func _physics_process(_delta: float) -> void:
	
	health_bar.value = health
	var dir = Input.get_axis("left","right")
	if dir>0:
		node.scale.x = 1
	elif dir<0:
		node.scale.x = -1
	
	
	muzzle_pivot.look_at(get_global_mouse_position())
	var angle = rad_to_deg((get_global_mouse_position()-muzzle_pivot.global_position).normalized().angle())
	if angle >90 or angle<-90:
		weapon_sprite.flip_v = true
	else:
		weapon_sprite.flip_v = false
	
	
	if abs(velocity.x)>0: sprite.play("walk")
	else:sprite.play("idle")
	
	if Input.is_action_pressed("mouse_left") and not EventBus.player_interacting and fire_interval.time_left==0 and not reloading:
		if ammo_in_mag>0:
			ammo_in_mag-=1
			for i in range(current_weapon.shells):
				shoot()
				EventBus.camera.screen_shake(current_weapon.recoil/2,0.2)
		else:
			reload()
	
	mag_array[current_weapon.weapon_id] = ammo_in_mag
	
	if Input.is_action_just_pressed("mouse_right") and not reloading:
		change_weapon()
	if Input.is_action_just_pressed("r") and not reloading and ammo_in_mag<mag_size:
		reload()
	
	if Input.is_action_just_pressed("q") and healthKits>0:
		healthKits-=1
		health = min(100,health+50)
	
	label.text = str(ammo_in_mag)+" / "+str(ammo_array[current_weapon.weapon_id])
	label_2.text = "healthKits: "+str(healthKits)

func take_damage(dmg):
	health = max(0,health-dmg)
	EventBus.camera.screen_shake(dmg/2,0.3)
	flash_hit()
	if health == 0:
		die()

func die():
	EventBus.player_died.emit()



func set_checkpoint():
	EventBus.start_info = [health,ammo_array,mag_array,weapon_resources]

func use_checkpoint():
	var info = EventBus.start_info
	health = info[0]
	ammo_array= info[1]
	mag_array = info[2]
	weapon_resources = info[3]
	equip_weapon(weapon_resources[0])


func equip_weapon(data:weapon_data):
	current_weapon = data
	fire_interval.wait_time = data.rate_of_fire
	mag_size = data.mag_size
	ammo_in_mag = mag_array[data.weapon_id]
	reload_timer.stop()
	reload_timer.wait_time = data.reload_time
	if data.weapon_texture:
		weapon_sprite.texture = data.weapon_texture
	gunshot_audio.stream = current_weapon.gunshot_audio
	reload_audio.stream = current_weapon.reload_audio

func change_weapon():
	var curr_idx = weapon_resources.find(current_weapon)
	var new_idx = 0
	if curr_idx+1 < len(weapon_resources): new_idx = curr_idx+1
	else: new_idx = 0
	print("changed   ",weapon_resources)
	if new_idx==curr_idx:return
	mag_array[current_weapon.weapon_id] = ammo_in_mag
	equip_weapon(weapon_resources[new_idx])
	if ammo_in_mag==0: reload()

func shoot():
	fire_interval.start()
	gunshot_audio.play()
	var bullet = bullet_scene.instantiate()
	level.add_child(bullet)
	
	var spread = deg_to_rad(randf_range(-current_weapon.bullet_spread,current_weapon.bullet_spread))
	var final_rot = muzzle_pivot.rotation + spread
	var dir = Vector2.from_angle(final_rot)
	bullet.dir = dir
	bullet.global_position = muzzle.global_position
	bullet.rotation = final_rot
	bullet.set_properties(current_weapon)
	position.x -= dir.x*current_weapon.recoil/2

func reload():
	reload_audio.play()
	var idx = current_weapon.weapon_id
	var amount = min(mag_size-ammo_in_mag,ammo_array[idx])
	if amount==0:return
	else:
		reloading = true
		reload_timer.start()
	

func _on_reload_timer_timeout() -> void:
	var idx = current_weapon.weapon_id
	var amount = min(mag_size-ammo_in_mag,ammo_array[idx])
	ammo_array[idx] -= amount
	ammo_in_mag += amount
	reloading = false
	if reload_audio.playing: reload_audio.stop()


func pickup_weapon(data:weapon_data):
	var id = data.weapon_id
	var mag = data.mag_size
	if weapon_ids[id]==0:
		weapon_ids[id] = 1
		weapon_resources.append(data)
	if reloading and current_weapon == data:
		reloading = false 
		ammo_in_mag = mag
	mag_array[id] = mag
	ammo_array[id]+=mag*2
	print("picked  ",weapon_resources)

func pickup_bullet(data:weapon_data):
	var id = data.weapon_id
	var mag = data.mag_size
	ammo_array[id]+=2*mag

func pickup_healthKit(id:int):
	if id==1:
		healthKits+=1
	elif id==2:
		health+=20
	health = min(100,health)


func flash_hit() -> void:
	sprite.self_modulate = Color(4.0, 0.3, 0.3, 1.0)
	await get_tree().create_timer(0.1).timeout
	sprite.self_modulate = Color.WHITE
