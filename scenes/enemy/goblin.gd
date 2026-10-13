extends Enemy
class_name GoblinEnemy


var direction = 1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

func _on_death() -> void:
	pass

func highlight(do_highlight:bool) -> void:
	super(do_highlight)
	pass

func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
	
	position.x += direction * speed * delta
