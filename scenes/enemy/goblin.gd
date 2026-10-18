extends Enemy
class_name GoblinEnemy


var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

@onready var marked: AnimatedSprite2D = $Marked
var is_highlighted = false
func highlight(do_highlight:bool) -> void:
	if do_highlight and not is_highlighted:
		is_highlighted = true
		marked.set_frame(0)
		marked.play("default", 1.)
	elif do_highlight == false and is_highlighted == true:
		is_highlighted = false
		marked.set_frame(0)
		marked.play_backwards("default")

func _on_death() -> void:
	super()
	pass


func _ready() -> void:
	super()
	self.direction = [1, -1].pick_random()

func _process(delta: float) -> void:
	if freeze: return
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
	
	position.x += direction * speed * 50 * delta
