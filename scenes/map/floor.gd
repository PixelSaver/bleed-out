extends StaticBody2D
class_name Floor

@export var mushrooms: Sprite2D
var og_scale: Vector2 = Vector2.ONE
var t: Tween

func _ready() -> void:
	og_scale = mushrooms.scale

func bounce() -> void:
	print("Bouncing")
	if t and t.is_running():
		t.kill()
	t = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	t.tween_property(mushrooms, "scale", og_scale * Vector2(1.1, 0.9), 0.7)
	#t.tween_property(mushrooms, "scale", og_scale * Vector2(0.9, 1.1), 0.7)
	t.tween_property(mushrooms, "scale", og_scale * Vector2.ONE, 0.7)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
