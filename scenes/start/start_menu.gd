extends PixelMenu
class_name StartMenu

@export var credits: PixelMenu
@export var cont: Container
@export var buttons: Array[StartMenuButton]
var all_t : Array[Tweenable] = []
var t: Tween 

func _ready() -> void:  
	all_t = get_all_tweenables(self)
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))


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
			if t and t.is_running(): t.kill()
			t = default_tween()
			t.tween_property(cont, "offset_transform_position_ratio:x", 0.375, 0.7)
			#var settings_scene = SceneDatabase.get_scene(SceneDatabase.Scene.SETTINGS)
			#Global.menu_manager.transition_to_scene(settings_scene)
			
		## From settings to play
		"back":
			if t and t.is_running(): t.kill()
			t = default_tween()
			t.tween_property(cont, "offset_transform_position_ratio:x", 0.0, 0.7)
		"credits":
			credits.start_anim()
			if t and t.is_running(): t.kill()
			t = default_tween()
			t.tween_property(cont, "offset_transform_position_ratio:x", 0.375/2, 0.7)
			t.tween_property(cont, "offset_transform_position_ratio:y", -0.2, 0.7)
			t.tween_property(cont, "offset_transform_scale", Vector2.ONE * 1.1, 0.7)
			t.tween_property(prototype, "size_flags_stretch_ratio", 16., 0.7)
		"creditsback":
			credits.end_anim()
			if t and t.is_running(): t.kill()
			t = default_tween()
			t.tween_property(cont, "offset_transform_position_ratio:x", 0.0, 1.2)
			t.tween_property(cont, "offset_transform_position_ratio:y", 0.0, 0.7)
			t.tween_property(cont, "offset_transform_scale", Vector2.ONE, 0.7)
			t.tween_property(prototype, "size_flags_stretch_ratio", 1., 0.7)
		"splash":
			Global.menu_manager.transition_to_scene(
				SceneDatabase.get_scene(SceneDatabase.Scene.SPLASH)
			)
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])
			#Log.warn("PixelMenu(%s) failed to find button name <%s>" % [self, _name])



func start_anim() -> void: pass
func end_anim() -> void: 
	queue_free()
