extends Node2D
class_name GrapplePoint

## Returns grapple global position
func get_grapple_pos() -> Vector2:
	return self.global_position
	
func get_enemy() -> Enemy:
	var par = get_parent()
	return par if par is Enemy else null
