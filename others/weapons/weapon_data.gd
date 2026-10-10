extends Resource
class_name weapon_data


@export var weapon_texture:Texture2D
@export var weapon_id = 1
@export var bullet_speed = 100
@export var bullet_id = 1
@export var bullet_sprite: Texture2D
@export var rate_of_fire = 0.1
@export var bullet_dmg = 10
@export var bullet_spread = 4
@export var mag_size = 30
@export var reload_time:float = 1
@export var recoil = 2
@export var shells = 1

@export var reload_audio:AudioStream
@export var gunshot_audio:AudioStream
