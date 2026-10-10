extends Node2D
class_name GrappleManager

var grapple_points: Array[GrapplePoint] = []


func _ready() -> void:
	Global.grapple_man = self
	for child in get_children():
		if child is GrapplePoint and not grapple_points.has(child):
			grapple_points.append(child)
			
## Returns closest grapple to the global player position, returns null if fails
func get_closest_grapple(global_player_position:Vector2) -> GrapplePoint:
	var out: GrapplePoint = null
	for grapple in grapple_points:
		if out == null:
			out = grapple
		elif grapple.global_position.distance_to(global_player_position) < \
			out.global_position.distance_to(global_player_position):
				out = grapple
	return out if out != null else null
