@tool
extends RadialContainer

class_name RadialSelector

@export var selector: Control
@export var offset: Vector2 = Vector2(0, 0)
var selector_target_global_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	super()
	var dynamic_offset = offset
	if flip:
		dynamic_offset.x *= -1.
		dynamic_offset.x -= selector.size.x
	selector_target_global_position = get_closest_position() + dynamic_offset
	scroll_to_index(0)


func _process(delta: float) -> void:
	super(delta)
	var dynamic_offset = offset
	if flip:
		dynamic_offset.x *= -1.
		dynamic_offset.x -= selector.size.x
	selector_target_global_position = get_closest_position() + dynamic_offset
	selector.global_position = selector.global_position.lerp(selector_target_global_position, delta * 10.)
	if _get_layout_children().size() == 0:
		selector.hide()
	else:
		selector.show()
