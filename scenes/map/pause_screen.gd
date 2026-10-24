extends PixelMenu
class_name PauseScreen

@export var buttons: Array[Button]
@export var all_t : Array[Tweenable] = []
@export var pause_tweenables: Array[Tweenable] = []
@export var hover_box: Panel
@export var settings_nodes: Array[Control]
@export var pause_nodes: Array[Control]
var is_settings := false
var t: Tween 

func _ready() -> void: 
	self.visible = true
	self.modulate.a = 0.
	
	self.hide()
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))
	hover_box.mouse_entered.connect(_on_hover.bind(true))
	hover_box.mouse_exited.connect(_on_hover.bind(false))

func _process(_d: float) -> void:
	if Input.is_action_just_pressed("attack"):
		_on_hover(true)
	if Input.is_action_just_released("attack"):
		_on_hover(false)

func _on_hover(mouse_inside: bool) -> void:
	if t and t.is_running():
		t.kill()
	t = default_tween()
	var a = 0. if mouse_inside else 1.
	t.tween_property(self, "modulate:a", a, 0.7)

func _on_button_pressed(_name:String) -> void:
	match _name.to_lower():
		"resume":
			SignalBus.request_pause.emit(false)
		"startover":
			SignalBus.request_pause.emit(false)
			Global.menu_manager.transition_to_scene(SceneDatabase.get_scene(SceneDatabase.Scene.START))
		"settings":
			if is_settings: return
			is_settings = true
			if t and t.is_running(): t.kill()
			t = default_tween()
			for table in pause_tweenables:
				t.tween_property(table, "tween_value", 1.0, 0.7)
			settings_nodes.front().grab_focus()
		"back":
			if not is_settings: return
			is_settings = false
			if t and t.is_running(): t.kill()
			t = default_tween()
			for table in pause_tweenables:
				t.tween_property(table, "tween_value", 0.0, 0.7)
			pause_nodes.front().grab_focus()
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])

func start_anim() -> void: 
	self.show()
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.7)
	pause_nodes.front().grab_focus()
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
	
