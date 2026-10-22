extends HSlider

@export var slider_progress: Panel
var max_x : float
var t: Tween


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	value_changed.connect(_on_value_changed)
	self.offset_transform_pivot_ratio = Vector2.ONE * 0.5
	await get_tree().process_frame
	max_x = slider_progress.size.x
	_on_value_changed(self.value)


func _on_value_changed(v: float) -> void:
	slider_progress.size.x = max_x * v


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			_hover()
		NOTIFICATION_MOUSE_EXIT:
			_unhover()
		NOTIFICATION_FOCUS_ENTER:
			pass
		NOTIFICATION_FOCUS_EXIT:
			pass

func _hover() -> void:
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "offset_transform_scale", Vector2.ONE * 1.05, 0.7)
	AudioManager.play_sfx(AudioManager.Sound.UI_HOVER, -10)
	
func _unhover() -> void:
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.7)
