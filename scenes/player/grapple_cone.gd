@tool
extends Area2D
class_name GrappleCone

@export var cone_col: CollisionPolygon2D
@export var cone_radius: int = 100 :
	set(val):
		cone_radius = val
		update_collision_polygon()
## The number of points on the edge of the cone
@export var cone_resolution: int = 2
@export var cone_angle: float = PI/2 :
	set(val):
		cone_angle = val
		update_collision_polygon()
@export var angle_penalty_falloff: Curve


func _ready() -> void:
	pass
	#update_collision_polygon()

func update_collision_polygon() -> void:
	if not cone_col: return
	var points : PackedVector2Array = []
	points.append(Vector2.ZERO)
	for i in range(cone_resolution + 1):
		var angle = -cone_angle / 2.0  + cone_angle * float(i) / cone_resolution
		points.append(Vector2.RIGHT.rotated(angle) * cone_radius)
	cone_col.polygon = points
	

func search_for_grapple_point(grapples: Array[GrapplePoint]) -> GrapplePoint:
	var candidates: Array = []
	
	for grapple in grapples:
		var point = grapple.get_grapple_pos()
		if not check_point(point): 
			continue
		
		var direction = (point - global_position)
		var angle_deviation: float = absf(
			wrapf(direction.angle() - global_rotation, -PI, PI)
		)
		## Increases the 'distance' for points that are further away 
		## from the centerline
		var angle_factor: float = 1.0 + angle_penalty_falloff.sample(
			remap(
				abs(angle_deviation), 
				0, cone_angle/2.,
				0, 1.0
			)
		)
		var virtual_distance: float = direction.length() * angle_factor
		candidates.append([grapple, virtual_distance])
	
	candidates.sort_custom(func(a, b):
		return a[1] < b[1]
	)
	if candidates.is_empty():
		return null
	return candidates[0][0]
	

func check_point(pos:Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = collision_layer
	
	var results := space_state.intersect_point(query)
	for result in results:
		if result.collider == self:
			return true
	return false
