extends PixelMenu
class_name StartMenu

@export var buttons: Array[DefaultButton]
var all_t : Array[Tweenable] = []
var t: Tween 

func _ready() -> void:  
	all_t = get_all_tweenables(self)
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		start_anim()
		
	elif Input.is_action_just_pressed("2"): 
		end_anim()

func _on_button_pressed(_name:String) -> void:
	match _name.to_lower():
		"tweenableshowcase":
			var tweenable_showcase = SceneDatabase.get_scene(SceneDatabase.Scene.TWEENABLE_SHOWCASE)
			Global.menu_manager.transition_to_scene(tweenable_showcase)
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])
			Log.warn("PixelMenu(%s) failed to find button name <%s>" % [self, _name])

func start_anim() -> void: pass
func end_anim() -> void: pass
