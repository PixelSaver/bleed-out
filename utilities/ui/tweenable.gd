@tool
class_name Tweenable
extends Node

@export_range(0.0, 1.0, .0001) var tween_value: float = 0.0:
	set(val):
		tween_value = val
		apply(val)
@export var use_local_transform := false
@export var direction: Vector2 = Vector2.ZERO
@export var distance: float = 100.0
@export_tool_button("Randomize distance") var randomize_action = _randomize_distance
@export var randomized_range := Vector2(0, 100)
var parent: Control


func _randomize_distance():
	distance = randf_range(randomized_range.x, randomized_range.y)


func _ready() -> void: 
	parent = get_parent() as Control
	if not parent:
		push_warning("Tweenable <%s> could not find it's parent, queue_free()ing" % self)
		queue_free()
	parent.offset_transform_enabled = true
	parent.offset_transform_pivot_ratio = Vector2.ONE * 0.5


func apply(t: float) -> void:
	var offset = direction.normalized() * distance * t
	if use_local_transform:
		offset *= parent.get_transform()

	parent.offset_transform_position = offset
