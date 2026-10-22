extends RigidBody2D
class_name Enemy

#@export var debug = ""

@export var touch_damage: float = 30.0
@export var touch_area: Area2D

@export var grapple_point: GrapplePoint
@export var health_component: HealthComponent
@export var marked: AnimatedSprite2D
@export var speed: float = 10.
signal frozen(is_frozen:bool)
var _queued_atk: Attack = null

func _ready() -> void:
	health_component.death.connect(_on_death)
	frozen.connect(_on_freeze)
	touch_area.body_entered.connect(_on_enemy_body_entered)

func _on_enemy_body_entered(body: Node2D) -> void:
	if freeze: return
	if body is not Player: return
	var p = body as Player
	if p == null: return
	var atk = Attack.new()
	atk.damage = touch_damage
	var dir = p.global_position - self.global_position
	dir = dir.normalized()
	atk.knockback = dir * 500
	p.damage(atk)

var is_highlighted = false
func highlight(do_highlight:bool) -> void:
	if do_highlight and not is_highlighted:
		is_highlighted = true
		#if marked == null:
			##print(debug)
		marked.set_frame(0)
		marked.play("default", 1.)
	elif do_highlight == false and is_highlighted == true:
		is_highlighted = false
		marked.set_frame(0)
		marked.play("default", -2., true)

func damage(atk:Attack) -> void:
	health_component.damage(atk)

## Function to toggle freezing of the enemy, stopping AI and special moves. 
## Queue an attack to be done when unfrozen
func freeze_enemy(do_freeze: bool=true, queued_atk: Attack=null) -> void:
	self.freeze = do_freeze
	frozen.emit(do_freeze)
	if do_freeze:
		_queued_atk = queued_atk
	elif _queued_atk != null:
		self.damage(_queued_atk)

func _on_freeze(_frozen: bool) -> void:
	
	pass

func _on_death() -> void:
	Global.enemy_man.unregister_enemy(self)
	queue_free()
	pass

func get_grapple_point() -> GrapplePoint:
	return grapple_point if grapple_point else null

#func highlight(do_highlight:bool) -> void:
	#$HighlightPROTOTYPE.color.a = 0.4 if do_highlight else 0.0
