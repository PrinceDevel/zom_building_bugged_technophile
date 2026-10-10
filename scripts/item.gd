extends Area2D

@export var item:item_data
@onready var sprite: Sprite2D = $Sprite2D
var texture

func _ready() -> void:
	sprite.texture = texture
	var tween = create_tween()
	var dutration = randf_range(0.5,1)
	
	tween.set_loops()
	tween.set_trans(Tween.TransitionType.TRANS_SINE)
	tween.set_ease(Tween.EaseType.EASE_IN_OUT)
	tween.tween_property(sprite,"offset",Vector2(0,-100),dutration)
	tween.tween_property(sprite,"offset",Vector2(0,0),dutration)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if item.weapon:
			body.pickup_weapon(item.weapon_resource)
		elif item.bullet:
			body.pickup_bullet(item.weapon_resource)
		elif item.healthKit_id:
			body.pickup_healthKit(item.healthKit_id)
	queue_free()

func setup(data:item_data):
	item = data
	if data.texture != null: 
		texture = data.texture
