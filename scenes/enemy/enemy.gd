extends RigidBody2D
class_name Enemy

@export var grapple_point: GrapplePoint

## BABEDUODKUk
func get_grapple_pos() -> GrapplePoint:
	return grapple_point.get_grapple_pos() if grapple_point else null

func highlight(do_highlight:bool) -> void:
	$ColorRect.color.a = 0.4 if do_highlight else 0.0
