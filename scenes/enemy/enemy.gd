extends RigidBody2D
class_name Enemy

@export var grapple_point: GrapplePoint

## BABEDUODKUk
func get_grapple_pos() -> GrapplePoint:
	return grapple_point.get_grapple_pos() if grapple_point else null

func _process(delta: float) -> void:
	if modulate != Color.WHITE:
		call_deferred("reset_col")

func reset_col() -> void:
	self_modulate = Color.WHITE
