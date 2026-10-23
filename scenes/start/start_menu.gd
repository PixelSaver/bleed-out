extends PixelMenu
class_name StartMenu

enum State {
	START,
	SETTINGS,
	CREDITS,
}
var state: State = State.START
@export var credits: PixelMenu
@export var cont: Container
@export var buttons: Array[StartMenuButton]
@export var start_first_focus: Control
@export var settings_first_focus: Control
@export var credits_first_focus: Control
@export var nav_mapper: NavMapper
var all_t : Array[Tweenable] = []
var t: Tween 

func _ready() -> void:  
	all_t = get_all_tweenables(self)
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))
	AudioManager.play_title_music()
	for path in nav_mapper.element_groups[0].elements_to_map:
		var n := nav_mapper.get_node(path) as Control
		n.focus_entered.connect(_on_start_focus)
	for path in nav_mapper.element_groups[1].elements_to_map:
		var n := nav_mapper.get_node(path) as Control
		n.focus_entered.connect(_on_settings_focus)
	for path in nav_mapper.element_groups[2].elements_to_map:
		var n := nav_mapper.get_node(path) as Control
		n.focus_entered.connect(_on_credits_focus)

func _on_start_focus() -> void:
	if state == State.START: return
	elif state == State.CREDITS:
		credits.end_anim()
		if t and t.is_running(): t.kill()
		t = default_tween()
		t.tween_property(cont, "offset_transform_position_ratio:x", 0.0, 1.2)
		t.tween_property(cont, "offset_transform_position_ratio:y", 0.0, 0.7)
		t.tween_property(cont, "offset_transform_scale", Vector2.ONE, 0.7)
		t.tween_property(prototype, "size_flags_stretch_ratio", 1., 0.7)
	state = State.START
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(cont, "offset_transform_position_ratio:x", 0.0, 0.7)
	start_first_focus.grab_focus()

func _on_settings_focus() -> void:
	if state == State.SETTINGS: return
	state = State.SETTINGS
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(cont, "offset_transform_position_ratio:x", 0.375, 0.7)
	settings_first_focus.grab_focus()
func _on_credits_focus() -> void:
	if state == State.CREDITS: return
	state = State.CREDITS
	if t and t.is_running(): t.kill()
	t = default_tween()
	t.tween_property(cont, "offset_transform_position_ratio:x", 0.375, 0.7)
	credits_first_focus.grab_focus()
	credits.start_anim()
	#if t and t.is_running(): t.kill()
	#t = default_tween()
	#t.tween_property(cont, "offset_transform_position_ratio:x", 0.375/2, 0.7)
	#t.tween_property(cont, "offset_transform_position_ratio:y", -0.2, 0.7)
	#t.tween_property(cont, "offset_transform_scale", Vector2.ONE * 1.1, 0.7)
	#t.tween_property(prototype, "size_flags_stretch_ratio", 16., 0.7)
	

@onready var prototype: Control = $AllContainer/PROTOTYPE
func _on_button_pressed(_name:String) -> void:
	match _name.to_lower():
		"play":
			if t and t.is_running(): t.kill()
			t = default_tween()
			t.tween_property(cont, "offset_transform_position_ratio:x", 0.375/2, 0.7)
			t.tween_property(prototype, "size_flags_stretch_ratio", 16., 0.3)
			await t.finished
			var game_scene = SceneDatabase.get_scene(SceneDatabase.Scene.GAME)
			Global.menu_manager.transition_to_scene(game_scene)
			pass
		"settings":
			_on_settings_focus()
			#var settings_scene = SceneDatabase.get_scene(SceneDatabase.Scene.SETTINGS)
			#Global.menu_manager.transition_to_scene(settings_scene)
			
		## From settings to play
		"back":
			_on_start_focus()
		"credits":
			_on_credits_focus()
		"creditsback":
			_on_start_focus()
		"splash":
			Global.menu_manager.transition_to_scene(
				SceneDatabase.get_scene(SceneDatabase.Scene.SPLASH)
			)
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])
			#Log.warn("PixelMenu(%s) failed to find button name <%s>" % [self, _name])



func start_anim() -> void: 
	start_first_focus.grab_focus()

func end_anim() -> void: 
	queue_free()
