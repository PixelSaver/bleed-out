extends Enemy
class_name GoblinEnemy


var direction = 1
@onready var goblin_sprite: AnimatedSprite2D = $GoblinSprite
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

func _on_death() -> void:
	super()
	pass

func _on_freeze(_frozen: bool) -> void:
	if _frozen:
		goblin_sprite.pause()

func _ready() -> void:
	super()
	self.direction = [1, -1].pick_random()

func _process(delta: float) -> void:
	if freeze: return
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
	self.apply_central_force(Vector2.RIGHT * speed * 15000 * delta * direction * randf_range(0.5, 1.5))
