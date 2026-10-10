extends PixelMenu
class_name TweenableShowcase

var all_t : Array[Tweenable] = []
var t: Tween 

func _ready() -> void: 
	all_t = get_all_tweenables(self)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("1"):
		start_anim()
	elif Input.is_action_just_pressed("2"):
		end_anim()

func start_anim() -> void: 
	print("All tweenable size: %s" % all_t.size())
	if t and t.is_running(): t.kill()
	t = default_tween()
	for table in all_t:
		t.tween_property(table, "tween_value", 1.0, 0.7)
func end_anim() -> void: 
	if t and t.is_running(): t.kill()
	t = default_tween()
	for table in all_t:
		t.tween_property(table, "tween_value", 0.0, 0.7)
