extends PixelMenu
class_name GrappleTest

@export var pause_screen: PixelMenu
@export var death_screen: DeathScreen

@export var score_label: ScoreLabel
@export var score_multiplier: float = 0.01

var all_t : Array[Tweenable] = []
var game_over := false

var score : int = 0


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
	
	var cur_score = roundi(-1 * score_multiplier * Global.player_ref.position.y)
	if (cur_score > score):
		score = cur_score
		score_label.update_score(score)
		

func _on_player_died() -> void:
	game_over = true
	pause(not get_tree().paused)
	death_screen.start_anim()
