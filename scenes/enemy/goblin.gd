extends Enemy
class_name GoblinEnemy


var direction = 1
@export var touch_damage: float = 5.
@export var touch_area: Area2D
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
		marked.play("default", -2., true)

func _on_death() -> void:
	super()
	pass


func _ready() -> void:
	super()
	self.direction = [1, -1].pick_random()
	touch_area.body_entered.connect(_on_enemy_body_entered)

func _on_enemy_body_entered(body: Node2D) -> void:
	if body is not Player: return
	var p = body as Player
	if p == null: return
	var atk = Attack.new()
	atk.damage = touch_damage
	var dir = p.global_position - self.global_position
	dir = dir.normalized()
	atk.knockback = dir * 500
	p.damage(atk)

func _process(delta: float) -> void:
	if freeze: return
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
	self.apply_central_force(Vector2.RIGHT * speed * 15000 * delta * direction)
