extends PixelMenu
class_name PauseScreen

@export var buttons: Array[Button]
@export var all_t : Array[Tweenable] = []
@export var pause_tweenables: Array[Tweenable] = []
var t: Tween 

func _ready() -> void: 
	self.visible = true
	self.modulate.a = 0.
	
	self.hide()
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))

func _on_button_pressed(_name:String) -> void:
	match _name.to_lower():
		"resume":
			SignalBus.request_pause.emit(false)
		"startover":
			SignalBus.request_pause.emit(false)
			Global.menu_manager.transition_to_scene(SceneDatabase.get_scene(SceneDatabase.Scene.START))
		"settings":
			if t and t.is_running(): t.kill()
			t = default_tween()
			for table in pause_tweenables:
				t.tween_property(table, "tween_value", 1.0, 0.7)
		"back":
			if t and t.is_running(): t.kill()
			t = default_tween()
			for table in pause_tweenables:
				t.tween_property(table, "tween_value", 0.0, 0.7)
			pass
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])

func start_anim() -> void: 
	self.show()
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.7)
	for table in all_t:
		table.tween_value = 1.0
		t.tween_property(table, "tween_value", 0.0, 0.7)
func end_anim() -> void:
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.7)
	for table in all_t:
		t.tween_property(table, "tween_value", 1.0, 0.7)
	await t.finished
	if is_equal_approx(self.modulate.a, 0.0):
		self.hide()
	var button_table : Array[Tweenable] = []
	for but in buttons:
		button_table.append(get_all_tweenables(but))
	for table in button_table:
		table.tween_value = 1.0
	
