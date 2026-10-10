extends Node
## Component to store health, takes damage using the Attack class.
## Also applies knockback, and can be resisted if the target node
## has the 'get_knockback_resistance' function
class_name HealthComponent 

## Emitted when health changes
signal health_changed(health, max_health)
## Emitted on death
signal death()

@export var health : float = 10.0 :
	set(val):
		if val != health:
			health = val
			health_changed.emit(health, max_health)
@export var max_health : float = 10.0 :
	set(val):
		if val != max_health:
			max_health = val
			health_changed.emit(health, max_health)
## The node (player/enemy) to own this health bar. If this is
## not set, the node will automatically use it's direct parent
## if it's a RigidBody2D
@export var target : RigidBody2D
var _target : RigidBody2D

var _pending_atks : Array[Attack] = []
var _processing := false

func _ready() -> void:
	if target != null:
		_target = target
	elif get_parent() != null and get_parent() is RigidBody2D:
		_target = get_parent()
	else:
		print_tree_pretty()
		push_error("Health component couldn't find target.")

func damage(atk: Attack):
	_pending_atks.append(atk)
	if not _processing:
		_processing = true
		call_deferred("_process_pending_damage")

func _process_pending_damage() -> void:
	var tot_damage := 0.0
	for atk in _pending_atks:
		tot_damage += atk.damage
		apply_knockback(atk)
	_pending_atks.clear()
	_processing = false
	health -= tot_damage
	if health <= 0 or is_equal_approx(health, 0.0):
		death.emit()

## Applies knockback unless target has the 'get_knockback_resistance' function
func apply_knockback(atk:Attack):
	var kb_res := 0.0
	if _target.has_method("get_knockback_resistance"):
		kb_res = _target.knockback_resistance
	_target.apply_central_impulse(atk.knockback * (1-kb_res))

func heal(delta:float) -> float:
	health += delta
	return health
