extends Button
# class_name CustomButton

var t : Tween

func _ready() -> void:
	self.pivot_offset_ratio = Vector2(0.5, 0.5)
	self.pressed.connect(_on_pressed)

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

func _on_pressed() -> void:
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT)
	t.tween_property(self, "scale", Vector2.ONE * 0.95, 0.07)
	t.tween_property(self, "scale", Vector2.ONE * 1.1, 0.07)
	

func _hover() -> void:
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE * 1.1, 0.7)
	
func _unhover() -> void:
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE, 0.7)
