extends PixelMenu
class_name GrappleTest

@export var pause_screen: PixelMenu
@export var death_screen: DeathScreen
var all_t : Array[Tweenable] = []
var game_over := false

func start_anim() -> void: pass
func end_anim() -> void: 
	self.hide()
	queue_free()

func _ready() -> void:
	SignalBus.request_pause.connect(pause)
	SignalBus.died.connect(_on_player_died)

func pause(do_pause: bool) -> void:
	if game_over:
		return
		
	get_tree().paused = do_pause
	if do_pause:
		pause_screen.start_anim()
	else:
		pause_screen.end_anim()

func _process(_d: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pause(not get_tree().paused)

func _on_player_died() -> void:
	print("on player died called")
	game_over = true
	get_tree().paused = true
	death_screen.start_anim()
