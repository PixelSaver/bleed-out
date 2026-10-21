extends PixelMenu
class_name GrappleTest

@export var pause_screen: PixelMenu
var all_t : Array[Tweenable] = []

func start_anim() -> void: pass
func end_anim() -> void: 
	self.hide()
	queue_free()

func _ready() -> void:
	SignalBus.request_pause.connect(pause)

func pause(do_pause: bool) -> void:
	get_tree().paused = do_pause
	if do_pause:
		pause_screen.start_anim()
	else:
		pause_screen.end_anim()

func _process(_d: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause(not get_tree().paused)
