extends Button
class_name StartMenuButton

@export var text_formatting: String = ""
@export var tweenable: Tweenable 
@export var front: RichTextLabel
@export var back: RichTextLabel
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
	AudioManager.play_sfx(AudioManager.Sound.UI_CLICK, -20)

func _hover() -> void:
	var parsed = front.get_parsed_text()
	front.clear()
	front.append_text(text_formatting)
	front.append_text("[shake rate=15 level=10]")
	front.append_text(parsed)
	back.clear()
	back.append_text(text_formatting)
	back.append_text("[shake rate=15 level=10]")
	back.append_text(parsed)
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE * 1.1, 0.7)
	t.tween_property(back, "offset_transform_position", Vector2(3,3), 0.7)
	t.tween_property(back, "modulate:a", 1., 0.7)
	if tweenable:
		t.tween_property(tweenable, "tween_value", 0.0, 0.7)
	AudioManager.play_sfx(AudioManager.Sound.UI_HOVER, -10., .00)
	
func _unhover() -> void:
	var parsed = front.get_parsed_text()
	front.clear()
	front.append_text(text_formatting)
	front.append_text("[shake rate=6 level=6]")
	front.append_text(parsed)
	back.clear()
	back.append_text(text_formatting)
	back.append_text("[shake rate=6 level=6]")
	back.append_text(parsed)
	if t and t.is_running(): t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(self, "scale", Vector2.ONE, 0.7)
	t.tween_property(back, "offset_transform_position", Vector2(0,0), 0.7)
	t.tween_property(back, "modulate:a", 0., 0.7)
	if tweenable:
		t.tween_property(tweenable, "tween_value", 1.0, 0.7)
