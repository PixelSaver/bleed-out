extends MarginContainer
class_name HPBar

@export var back: Panel
@export var front: Panel
var true_health_proportion: float = 1.0
var front_health_proportion: float = 1.0
var back_health_proportion: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	Global.player_ref.health_component.health_changed.connect(_on_health_changed)
	back.offset_transform_pivot_ratio = Vector2(0, 1.)
	front.offset_transform_pivot_ratio = Vector2(0, 1.)

func _on_health_changed(h: float, mh: float) -> void:
	var p = h / mh
	true_health_proportion = p

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if back_health_proportion < front_health_proportion:
		back_health_proportion = front_health_proportion
	front_health_proportion = clampf(
		#lerp(front_health_proportion, true_health_proportion, delta * 100.),
		true_health_proportion,
		0.,
		1.,
	)
	front.offset_transform_scale.y = front_health_proportion
	back_health_proportion = clampf(
		lerp(back_health_proportion, true_health_proportion, delta * 3.),
		0.,
		1.,
	)
	back.offset_transform_scale.y = back_health_proportion
