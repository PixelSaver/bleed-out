extends PixelMenu
class_name CreditsMenu

@export var cont: Container
@export var scroll: ScrollContainer
@export var buttons: Array[Button]
var all_t : Array[Tweenable] = []
var t: Tween 

func _ready() -> void: 
	self.hide()
	all_t = get_all_tweenables(self)
	for but in buttons:
		but.pressed.connect(_on_button_pressed.bind(but.name))

func _on_button_pressed(_name:String) -> void:
	match _name.to_lower():
		"top":
			scroll.scroll_vertical = 0
			print("Went to top")
		_:
			push_warning("PixelMenu(%s) failed to find button name <%s>" % [self, _name])

func _process(_d: float) -> void:
	if visible:
		cont.offset_transform_position.y = -scroll.scroll_vertical 
		if Input.is_action_pressed("ui_text_scroll_down") or Input.is_action_pressed("ui_down"):
			scroll.scroll_vertical += 10
		if Input.is_action_pressed("ui_text_scroll_up") or Input.is_action_pressed("ui_up"):
			scroll.scroll_vertical -= 10
	else:
		cont.offset_transform_position.y = 0

func start_anim() -> void: 
	self.show()
func end_anim() -> void: 
	self.hide()
