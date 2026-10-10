extends PixelMenu
#class_name NAME

@export var buttons: Array[DefaultButton]
var all_t : Array[Tweenable] = []
var t: Tween 

func _ready() -> void: 
	all_t = get_all_tweenables(self)
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))

func _on_button_pressed(_name:String) -> void:
	match _name.to_lower():
		"play":
			pass
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])

func start_anim() -> void: pass
func end_anim() -> void: pass
