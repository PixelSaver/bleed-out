@tool
extends Button
class_name DefaultButton

var t : Tween

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	call_deferred("_ensure_label")
func _ensure_label():
	if self.custom_minimum_size == Vector2.ZERO:
		self.custom_minimum_size = Vector2(150, 80) 
	
	for child in get_children():
		if child is RichTextLabel:
			return
	var label = RichTextLabel.new()
	add_child(label)
	label.owner = get_tree().edited_scene_root # required for editor persistence
	label.fit_content = true
	label.scroll_active = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.shortcut_keys_enabled = false
	label.clip_contents = false
	label.text = "Default Button"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.bbcode_enabled = true
	label.set_anchors_preset(Control.PRESET_FULL_RECT)

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
