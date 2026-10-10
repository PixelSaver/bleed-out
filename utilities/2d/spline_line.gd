@tool
extends Line2D
class_name SplineLine

@export var start_pos: Vector2 = Vector2.ZERO:
	set(v):
		start_pos = v
		_update_curve()
@export var end_pos: Vector2 = Vector2.ZERO:
	set(v):
		end_pos = v
		_update_curve()
@export var handle_length := 100.0:
	set(v):
		handle_length = v
		_update_curve()
@export var resolution := 24:
	set(v):
		resolution = v
		_update_curve()
@export_range(0.0, 1.0) var display_proportion := 1.0 :
	set(v):
		display_proportion = v
		_update_curve()
@export var display_handles := true :
	set(v):
		display_handles = v
		_update_curve()

var curve := Curve2D.new()

var start_handle : Vector2
var end_handle : Vector2

func _ready():
	await get_tree().process_frame
	_update_curve()

func _update_curve():
	if not width_curve: width_curve = Curve.new()
	width_curve.clear_points()
	if is_equal_approx(display_proportion, 0.0):
		width_curve.add_point(Vector2(0, 0))

	elif is_equal_approx(display_proportion, 1.0):
		width_curve.add_point(Vector2(0, 1))
	else:
		width_curve.add_point(Vector2(0, 1), 0, 0, Curve.TANGENT_FREE, Curve.TANGENT_FREE)
		width_curve.add_point(Vector2(display_proportion, 0), 0, 0, Curve.TANGENT_FREE, Curve.TANGENT_FREE)
		width_curve.add_point(Vector2(display_proportion, 1), 0, 0, Curve.TANGENT_FREE, Curve.TANGENT_FREE)
		width_curve.add_point(Vector2(1, 0), 0, 0, Curve.TANGENT_FREE, Curve.TANGENT_FREE)
	
	curve.clear_points()

	start_handle = start_pos + Vector2.RIGHT * handle_length
	end_handle   = end_pos   + Vector2.LEFT  * handle_length

	var start_local = to_local(start_pos)
	var end_local   = to_local(end_pos)

	var start_handle_local = to_local(start_handle)
	var end_handle_local   = to_local(end_handle)

	curve.add_point(
		start_local,
		Vector2.ZERO,
		start_handle_local - start_local
	)
	curve.add_point(
		end_local,
		end_handle_local - end_local,
		Vector2.ZERO
	)
	points = curve.get_baked_points()

	queue_redraw()
	
func _draw():
	if Engine.is_editor_hint() and display_handles: 
		draw_circle(start_pos, 5, Color.GREEN)
		draw_circle(end_pos, 5, Color.RED)

		draw_circle(start_handle, 4, Color.YELLOW)
		draw_circle(end_handle, 4, Color.YELLOW)

		draw_line(start_pos, start_handle, Color.YELLOW, 1)
		draw_line(end_pos, end_handle, Color.YELLOW, 1)
