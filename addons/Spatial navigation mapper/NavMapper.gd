@tool
extends Control
class_name NavMapper

@export_tool_button("Map navigation", "CanvasItem") var ClickMeButton = QueueRemap

var mapping_queued : bool = false
var debug : bool = false
## key used alongside alt + (key) to toggle visibility of mapper node.
@export var alt_and_hotkey_to_hide : Key = KEY_H
## Controls whether visibility can be toggled via hotkey while at runtime.
@export var lock_visibility_toggle_at_runtime : bool = true
var visibility_input_lock : bool = false
var empty_warning_printed : bool = false

## Disables any automatic in-editor update checks based on node position & scale changes, relying only on manual update calls. At runtime, any position and scale changes are not checked regardless of setting
@export var disable_auto_update : bool = false
enum AutoUpdateTypes 
{
	## Allows calculation and updating of all values - This includes overwriting any custom changes to navigation mapping
	All, 
	## Updates only debug visualization for in-group mapping - Note: group-to-group mapping is still calculated and updated, but respects any manually changed mapping between elements of the same group
	Visualization
}

## Controls whether updates are full re-calculations, or just visualization
@export var update_type : AutoUpdateTypes = AutoUpdateTypes.All

## By default element movement and scale change checks happen via physics process update (default: 60 times a second), 'true' limits this by half if for whatever reason the default is too computationally heavy
@export var limit_update_frames : bool = false

## Automatically sets base godot focus mode of all mapped nodes to either all or none, to allow for custom navigation control & selection solutions instead
@export var allow_base_godot_focus : bool = true:
	get: return allow_base_godot_focus
	set(value):
		allow_base_godot_focus = value
		QueueRemap()

## Controls whether focus targets for next & previous are set to disabled (self), or calculated by godot (empty) - This tool has no custom calculations or debug visuals for either, so 'false' by default
@export var allow_base_godot_next_and_previous : bool = false:
	get: return allow_base_godot_next_and_previous
	set(value):
		allow_base_godot_next_and_previous = value
		QueueRemap()

@export_category("Parameters")
## Control element group array: these store all to-be-mapped target elements, as well as other parameters & data
@export var element_groups : Array[NavMapGroup]:
	get:
		return element_groups
	set(value):
		element_groups = value
		for group in element_groups:
			if group != null:
				group.parent_mapper = self
		QueueRemap()

## Controls how many calculation points are generated for each edge of potential target element (Currently a flat amount for every edge of element regardless of the size of the edge)
@export_range(1,999,1.0,"suffix: points per edge") var check_resolution : int = 7:
	get:
		return check_resolution
	set(value):
		check_resolution = value
		QueueRemap()

## Maximum allowed angle of calculated points to be considered valid
@export_range(0,90,0.1,"suffix:degrees") var maximum_target_angle : float = 30.0:
	get:
		return maximum_target_angle
	set(value):
		maximum_target_angle = value
		QueueRemap()

## Same as maximum target angle, but for group-to-group calculations
@export_range(0,90,0.1,"suffix:degrees") var maximum_group_target_angle : float  = 30.0:
	get:
		return maximum_group_target_angle
	set(value):
		maximum_group_target_angle = value
		QueueRemap()

## Controls whether for vertical mapping (up / down), origin is calculated from center (false: position.x + width.x / 2) 
## or from a left-biased position (true: position + width / 4) to give control nodes on the left a higher value
@export var use_left_bias : bool = true:
	get:
		return use_left_bias
	set(value):
		use_left_bias = value
		QueueRemap()

## Controls maximum distance that a point is allowed to have before it is deemed invalid. -1 sets this as infinite, so no target is ever deemed too far.
@export_range(-1.0,4000,2.0,"suffix:units") var distance_cut_off : float = -1.0:
	get:
		return distance_cut_off
	set(value):
		distance_cut_off = value
		QueueRemap()

## Custom resource used by this node to store and reference calculated mapping data.
## If to want to manually change calculated in-group pathing, use 'Visualization' auto-update mode.
## Note that since group-to-group mapping is updated even in visualization-only mode, any nodes outside of node's own group will be removed.
@export var navigation_references : Dictionary[String, NavMapReference]

@export_group("Visuals")
## Resource for overriding debug visual colors and other parameters for easier use of custom visual settings through multiple instances. Note: updating values of override resource does not call a redraw for the parent mapper node it is in
@export var visual_override : NavMapVisualOverride:
	get:
		return visual_override
	set(value):
		visual_override = value
		queue_redraw()

## Scaling value for all visualization
@export_range(1.0,10.0,0.01) var visuals_scaling_value : float = 1.0: 
	get:
		return visuals_scaling_value
	set(value):
		visuals_scaling_value = value
		queue_redraw()

## Controls overall opacity of all debug visuals
@export_range(0,100.0,0.1,"suffix:%") var opacity : float = 100.0:
	get:
		return opacity
	set(value):
		opacity = value
		queue_redraw()

## Color used for arrows of up-direction mapping
@export var up_color : Color = Color(0.89, 0.34, 0.18, 1.00):
	get:
		return up_color
	set(value):
		up_color = value
		queue_redraw()

## Color used for arrows of down-direction mapping
@export var down_color : Color = Color(0.00, 0.62, 1.00, 1.00):
	get:
		return down_color
	set(value):
		down_color = value
		queue_redraw()

## Color used for arrows of left-direction mapping
@export var left_color : Color = Color(0.67, 0.85, 0.36, 1.00):
	get:
		return left_color
	set(value):
		left_color = value
		queue_redraw()

## Color used for arrows of right-direction mapping
@export var right_color : Color = Color(0.73, 0.22, 0.60, 1.00):
	get:
		return right_color
	set(value):
		right_color = value
		queue_redraw()

## Color used for group container box visuals
@export var group_box_color : Color = Color(0.95, 1.0, 0.0, 0.298):
	get:
		return group_box_color
	set(value):
		group_box_color = value
		queue_redraw()

## Color used for arrows of up-direction group-to-group mapping
@export var group_up_color : Color = Color(1.0, 0.541, 0.0, 1.00):
	get:
		return group_up_color
	set(value):
		group_up_color = value
		queue_redraw()

## Color used for arrows of down-direction group-to-group mapping
@export var group_down_color : Color = Color(0.00, 0.30, 1.00, 1.00):
	get:
		return group_down_color
	set(value):
		group_down_color = value
		queue_redraw()

## Color used for arrows of left-direction group-to-group mapping
@export var group_left_color : Color = Color(0.39, 0.93, 0.59, 1.00):
	get:
		return group_left_color
	set(value):
		group_left_color = value
		queue_redraw()

## Color used for arrows of right-direction group-to-group mapping
@export var group_right_color : Color = Color(0.98, 0.13, 0.4, 1.00):
	get:
		return group_right_color
	set(value):
		group_right_color = value
		queue_redraw()

## Fontsize of group label
@export_range(1.0,100.0,1.0) var group_label_size : int = 12:
	get:
		return group_label_size
	set(value):
		group_label_size = value
		queue_redraw()

## Controls padding of group container box
@export var group_box_padding : int = 6:
	get:
		return group_box_padding
	set(value):
		group_box_padding = clamp(value,-1,999)
		queue_redraw()

## Texture used by group container box
@export var group_container_tex : Texture2D = load("res://addons/Spatial navigation mapper/ContainerBorder_box_ants.png"):
	get:
		return group_container_tex
	set(value):
		group_container_tex = value
		queue_redraw()
		pass

## Patch margin of Nine-slice group box texture
@export_range(1.0,999.0,1.0) var group_box_patch_margin : int = 1:
	get:
		return group_box_patch_margin
	set(value):
		group_box_patch_margin = value
		queue_redraw()
		pass

## Texture used by mapping visualization arrows
@export var arrow_tex : Texture2D = load("res://addons/Spatial navigation mapper/arrow.png"):
	get:
		return arrow_tex
	set(value):
		arrow_tex = value
		queue_redraw()

var directions : Array[Vector2] = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
var angles : Array[float]
var finals : Array[float]
var distances : Array[float]
var element_sizes : Array[Vector2]
var element_positions : Array[Vector2]
var point_parents : Array[Control]
var group_point_parents : Array[NavMapGroup]
var point_positions : Array[Vector2]
var full_list_of_elements : Array[Control]
var current_whole_index : int
var current_selected : Control

var first_item_highlight_tex : Texture2D = load("res://addons/Spatial navigation mapper/ContainerBorder_box.png")
var first_item_highlight_tex_left : Texture2D = load("res://addons/Spatial navigation mapper/first_element_4.png")
var first_item_highlight_tex_right : Texture2D = load("res://addons/Spatial navigation mapper/first_element_5.png")
var first_item_highlight_tex_top : Texture2D = load("res://addons/Spatial navigation mapper/first_element_6.png")
var first_item_highlight_tex_bottom : Texture2D = load("res://addons/Spatial navigation mapper/first_element_7.png")
var first_item_highlight_tex_topleft : Texture2D = load("res://addons/Spatial navigation mapper/first_element_1.png")
var first_item_highlight_tex_topright : Texture2D = load("res://addons/Spatial navigation mapper/first_element_2.png")
var first_item_highlight_tex_botleft : Texture2D = load("res://addons/Spatial navigation mapper/first_element_0.png")
var first_item_highlight_tex_botright : Texture2D = load("res://addons/Spatial navigation mapper/first_element_3.png")

## Controls whether directional letters are drawn alongside arrows [U(p), D(own), L(eft), R(ight)]
@export var draw_direction_letter : bool = false:
	get:
		return draw_direction_letter
	set(value):
		draw_direction_letter = value
		queue_redraw()

## Controls whether visualization is drawn for direction-specific 'entry-target' of group, which can be changed within navigation group -> 'Entry selection indexes'. For any mappings with only one group, disabled automatically
@export var draw_group_entry_elements : bool = true:
	get:
		return draw_group_entry_elements
	set(value):
		draw_group_entry_elements = value
		queue_redraw()

var check_frame : int


func _enter_tree():
	for i in navigation_references:
		navigation_references[i].parent_mapper = self
	for i in element_groups.size():
		element_groups[i].parent_mapper = self


func _exit_tree():
	for i in navigation_references:
		navigation_references[i].parent_mapper = null
	for i in element_groups.size():
		element_groups[i].parent_mapper = null


func _ready():
	if (Engine.is_editor_hint()):
		CheckStartMapping()
	else:
		visible = false


func QueueOnlyManualUpdate(msg):
	if (update_type == AutoUpdateTypes.Visualization):
		QueueRemap()


func QueueRemap():
	if(IsReadyToMap()):
		mapping_queued = true


func _notification(what):
	if(is_transform_notification_enabled() == false):
		set_notify_transform(true)
	if(what == NOTIFICATION_DRAW):
		DrawVisualization()


func DrawVisualization():
	# generate group boxes
	DrawGroupBoxes()

	var used_arrow_tex : Texture2D = arrow_tex if visual_override == null else visual_override.arrow_tex
	# generate group arrows
	SetupDrawGroupToGroupArrows(used_arrow_tex)
	# generate element arrows
	DrawInGroupArrows(used_arrow_tex)

	# highlight group primary element using a box
	if(draw_group_entry_elements && element_groups.size() > 1):
		GenerateGroupFirstSelectionBoxes()

	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(), true, get_viewport_rect())
	RenderingServer.canvas_item_set_default_texture_filter(get_canvas_item(), RenderingServer.CanvasItemTextureFilter.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)


func GenerateGroupBoundingBoxes():
	for group in element_groups:
		var smallest = Vector2(999999999, 999999999)
		var largest = -smallest
		var element_array : Array[Control] = CreateControlElementArray(group)
		for mappable_element in element_array:
			if (mappable_element.global_position.x <= smallest.x):
				smallest.x = mappable_element.global_position.x
			if (mappable_element.global_position.y <= smallest.y):
				smallest.y = mappable_element.global_position.y

			if (mappable_element.global_position.x + mappable_element.size.x >= largest.x):
				largest.x = mappable_element.global_position.x + mappable_element.size.x
			if (mappable_element.global_position.y + mappable_element.size.y >= largest.y):
				largest.y = mappable_element.global_position.y+  mappable_element.size.y

		group.group_bounding_box_position = smallest
		group.group_bounding_box_size = Vector2(abs(largest.x - smallest.x),abs(largest.y - smallest.y))


func DrawGroupBoxes():
	if (group_container_tex == null):
		printerr("Group container box texture missing")
		return
	var index : int = 0
	for group in element_groups:
		if (group != null):
			var rect_RID = get_canvas_item()
			var clr = (group_box_color if visual_override == null else visual_override.group_box_color)
			var final_clr = ModifyColorAlpha(clr, VisualOpacityValue())
			DrawNinePatchRect(group.group_bounding_box_position, group.group_bounding_box_size, group_container_tex, final_clr, group_box_padding, group_box_patch_margin, RenderingServer.NinePatchAxisMode.NINE_PATCH_TILE)

			RenderingServer.canvas_item_add_set_transform(rect_RID, Transform2D(Vector2.RIGHT, Vector2.DOWN, group.group_bounding_box_position + Vector2.UP * (group_box_padding + 4) + Vector2.LEFT * group_box_padding))
			var text_server = TextServerManager.get_primary_interface()
			var base_font = get_window().get_theme_default_font()
			var shaped_text = text_server.create_shaped_text()
			var name_text = "Group " + str(index)
			var size = (group_label_size if visual_override == null else visual_override.group_label_size) * UsedScalingValue()
			text_server.shaped_text_add_string(shaped_text, name_text, base_font.get_rids(), size)
			text_server.shaped_text_draw(shaped_text, rect_RID, Vector2.ZERO, -1, -1, final_clr)

		index += 1


func DrawNinePatchRect(pos : Vector2, box_size : Vector2, box_texture : Texture2D, color : Color, padding : int, patch_margin : int, axis_mode : RenderingServer.NinePatchAxisMode):
	var rect_RID = get_canvas_item()
	var padding_vector = Vector2(padding, padding)
	var transform = Transform2D(Vector2.RIGHT * UsedScalingValue(), Vector2.DOWN * UsedScalingValue(), pos - padding_vector)
	var b_size = box_size + padding_vector * 2
	var rect = Rect2(Vector2.ZERO, b_size / UsedScalingValue())
	RenderingServer.canvas_item_add_set_transform(rect_RID, transform)
	RenderingServer.canvas_item_add_nine_patch(rect_RID, rect, Rect2(), box_texture.get_rid(), Vector2(patch_margin, patch_margin), Vector2(patch_margin, patch_margin), axis_mode, axis_mode, true, color)


func SetupDrawGroupToGroupArrows(tex: Texture2D):
	var arrow_width = round(tex.get_size().y)
	for group in element_groups:
		if (group != null):
			var arrow_RID = tex.get_rid()
			if (group.direction_group_target_index_up > -1):
				DrawGroupArrow(Vector2.UP, element_groups[group.direction_group_target_index_up], group, (group_up_color if visual_override == null else visual_override.group_up_color), arrow_RID, arrow_width)

			if (group.direction_group_target_index_left > -1):
				DrawGroupArrow(Vector2.LEFT, element_groups[group.direction_group_target_index_left], group, (group_left_color if visual_override == null else visual_override.group_left_color), arrow_RID, arrow_width)

			if (group.direction_group_target_index_right > -1):
				DrawGroupArrow(Vector2.RIGHT, element_groups[group.direction_group_target_index_right], group, (group_right_color if visual_override == null else visual_override.group_right_color), arrow_RID, arrow_width)
			
			if (group.direction_group_target_index_down > -1):
				DrawGroupArrow(Vector2.DOWN, element_groups[group.direction_group_target_index_down], group, (group_down_color if visual_override == null else visual_override.group_down_color), arrow_RID, arrow_width)


func DrawGroupArrow(direction : Vector2, target_group : NavMapGroup, group: NavMapGroup, color : Color, arrow_RID : RID, arrow_width : int):
	var group_pos = group.group_bounding_box_position
	var group_size = group.group_bounding_box_size
	var target_pos = target_group.group_bounding_box_position
	var target_size = target_group.group_bounding_box_size
	var edge_beyond = OppositeEdgeBeyondEdge(direction, group_pos, group_size, target_pos, target_size)
	DrawLineFromPositionToTarget(target_pos, target_size, group_pos, group_size, arrow_RID, arrow_width, color, direction, group_box_padding, edge_beyond, false)


func DrawInGroupArrows(tex: Texture2D):
	var arrow_width = round(tex.get_size().y)
	for key in GetNavRefDictionary():	
		var navigation_reference : NavMapReference = navigation_references[key]
		if (navigation_reference == null):
			printerr(key + " navigation reference is null?")
			return

		var origin_node : Control = get_node_or_null(navigation_reference.origin)
		if (origin_node == null):
			printerr(key + " origin node is null at in-group arrow draw call, this may be caused by navigation reference building errors - aborting.")
			return

		var up_target = TargetIsInSameGroup(navigation_reference, navigation_reference.up)
		if (up_target != null):
			DrawLineFromPositionToTarget(up_target.global_position, up_target.size, origin_node.global_position, origin_node.size, arrow_tex.get_rid(), arrow_width, (up_color if visual_override == null else visual_override.up_color), Vector2.UP, 0.0, OppositeEdgeBeyondEdge(Vector2.UP, origin_node.global_position, origin_node.size, up_target.global_position, up_target.size), use_left_bias)

		var left_target = TargetIsInSameGroup(navigation_reference, navigation_reference.left)
		if (left_target != null):
			DrawLineFromPositionToTarget(left_target.global_position, left_target.size, origin_node.global_position, origin_node.size, arrow_tex.get_rid(), arrow_width, (left_color if visual_override == null else visual_override.left_color), Vector2.LEFT, 0.0, OppositeEdgeBeyondEdge(Vector2.LEFT, origin_node.global_position, origin_node.size, left_target.global_position, left_target.size), use_left_bias)

		var right_target = TargetIsInSameGroup(navigation_reference, navigation_reference.right)
		if (right_target != null):
			DrawLineFromPositionToTarget(right_target.global_position, right_target.size, origin_node.global_position, origin_node.size, arrow_tex.get_rid(), arrow_width, (right_color if visual_override == null else visual_override.right_color), Vector2.RIGHT, 0.0, OppositeEdgeBeyondEdge(Vector2.RIGHT, origin_node.global_position, origin_node.size, right_target.global_position, right_target.size), use_left_bias)

		var down_target = TargetIsInSameGroup(navigation_reference, navigation_reference.down)
		if (down_target != null):
			DrawLineFromPositionToTarget(down_target.global_position, down_target.size, origin_node.global_position, origin_node.size, arrow_tex.get_rid(), arrow_width, (down_color if visual_override == null else visual_override.down_color), Vector2.DOWN, 0.0, OppositeEdgeBeyondEdge(Vector2.DOWN, origin_node.global_position, origin_node.size, down_target.global_position, down_target.size), use_left_bias)


func TargetIsInSameGroup(navigation_reference : NavMapReference, matchable_target : NodePath):
	if (element_groups[navigation_reference.group_index].elements_to_map.has(matchable_target)):
		return get_node_or_null(matchable_target)
	else:
		return null


func DrawLineFromPositionToTarget(target_position: Vector2,  target_size: Vector2, origin_position: Vector2, origin_size: Vector2, arrow_tex_rid: RID, arrow_width: int, used_color: Color, direction: Vector2, padding: float, target_edge_behind: bool, bias : bool):
	var rect_RID = get_canvas_item()
	var vertical_check_horizontal_pos = round(origin_size.x / (4 if bias else 2))
	var origin_starting_point : Vector2 = Vector2(0.0, 0.0)
	match direction:
		Vector2(0.0, -1.0):
			origin_starting_point = origin_position + Vector2(vertical_check_horizontal_pos, 0 - padding)
		Vector2(0.0, 1.0):
			origin_starting_point = origin_position + Vector2(vertical_check_horizontal_pos, origin_size.y + padding)
		Vector2(-1.0, 0.0):
			origin_starting_point = origin_position + Vector2(0 - padding, origin_size.y / 2)
		Vector2(1.0, 0.0):
			origin_starting_point = origin_position + Vector2(origin_size.x + padding, origin_size.y / 2)

	var x_position_limiter  = clamp(origin_starting_point.x, target_position.x - padding + arrow_width, target_position.x + target_size.x + padding - arrow_width)
	var y_position_limiter  = clamp(origin_starting_point.y, target_position.y - padding + arrow_width, target_position.y + target_size.y + padding - arrow_width)
	var target_position_with_offset : Vector2 = Vector2(0.0, 0.0)
	match direction:
		Vector2(0.0, -1.0):
			target_position_with_offset = Vector2(x_position_limiter, target_position.y + target_size.y + padding)
		Vector2(0.0, 1.0):
			target_position_with_offset = Vector2(x_position_limiter, target_position.y - padding)
		Vector2(-1.0, 0.0):
			target_position_with_offset = Vector2(target_position.x + target_size.x + padding, y_position_limiter)
		Vector2(1.0, 0.0):
			target_position_with_offset = Vector2(target_position.x - padding, y_position_limiter)


	if (target_edge_behind): # this is simply to limit rotation and target position of arrow, in rare instances where specified target edge is away from origin edge
		if (direction.y != 0):
			if ((target_position.x + target_size.x / 2) > (origin_position.x + origin_size.x / 2)):
				target_position_with_offset = Vector2(target_position.x - padding, y_position_limiter)
			else:
				target_position_with_offset = Vector2(target_position.x + target_size.x + padding, y_position_limiter)
		else:
			if ((target_position.y + target_size.y / 2) > (origin_position.y + origin_size.y / 2)):
				target_position_with_offset = Vector2(x_position_limiter, target_position.y - padding)
			else:
				target_position_with_offset = Vector2(x_position_limiter, target_position.y + target_size.y + padding)

	var from_to_vector : Vector2 = CalculateRelativeVector(target_position_with_offset, origin_starting_point)
	var rect = Rect2(Vector2.ZERO, Vector2(round(from_to_vector.length() / UsedScalingValue()), arrow_width))
	var right_rotated : Vector2 = RotateVectorWithAnother(from_to_vector.normalized().rotated(-PI/2), Vector2.RIGHT)
	var down_rotated : Vector2 = RotateVectorWithAnother(from_to_vector.normalized().rotated(-PI/2), Vector2.DOWN)
	var scaling_position_offsetter : Vector2 = down_rotated * arrow_width * 0.5 *(UsedScalingValue() - 1.0)
	var arrow_transform = Transform2D(right_rotated * UsedScalingValue(), down_rotated * UsedScalingValue(), origin_starting_point - scaling_position_offsetter)
	RenderingServer.canvas_item_add_set_transform(rect_RID, arrow_transform)
	RenderingServer.canvas_item_add_texture_rect(rect_RID, rect, arrow_tex_rid, true, ModifyColorAlpha(used_color, VisualOpacityValue()))

	if (draw_direction_letter):
		var pos = origin_starting_point + from_to_vector * 0.5 + down_rotated * arrow_width * 2.5 * UsedScalingValue()
		DoDrawDirectionLetter(pos, down_rotated, rect_RID, direction, used_color)

func DoDrawDirectionLetter(pos : Vector2, down_rotated : Vector2, rect_rid : RID, direction : Vector2, used_color : Color):
	var font_size = roundi(12 * UsedScalingValue())
	var directional_offsetter : Vector2 = (down_rotated * font_size / 2) if (direction == Vector2(0.0, -1.0) || direction == Vector2(-1.0, 0.0)) else Vector2.ZERO
	RenderingServer.canvas_item_add_set_transform(rect_rid, Transform2D(Vector2.RIGHT, Vector2.DOWN, pos - directional_offsetter))
	var text_server = TextServerManager.get_primary_interface()
	var base_font = get_window().get_theme_default_font()
	var shaped_text = text_server.create_shaped_text()
	text_server.shaped_text_add_string(shaped_text, GetDirectionLetter(direction), base_font.get_rids(), font_size)
	text_server.shaped_text_draw(shaped_text, rect_rid, Vector2.ZERO, -1, -1, used_color)

func GetNavRefDictionary():
		var keys : Array[String] = []
		for key in navigation_references:
			keys.append(key);
		return keys


func GenerateGroupFirstSelectionBoxes():
	for group in element_groups:
		var all_indexes : Array[int] = [group.from_left_entry_selection_index, group.from_right_entry_selection_index, group.from_bottom_entry_selection_index, group.from_top_entry_selection_index]
		var used_indexes : Array[int] = []

		PrepFirstSelectionBoxDraw(group, group.from_left_entry_selection_index, Vector2.RIGHT, all_indexes, used_indexes)
		PrepFirstSelectionBoxDraw(group, group.from_right_entry_selection_index, Vector2.LEFT, all_indexes, used_indexes)
		PrepFirstSelectionBoxDraw(group, group.from_bottom_entry_selection_index, Vector2.UP, all_indexes, used_indexes)
		PrepFirstSelectionBoxDraw(group, group.from_top_entry_selection_index, Vector2.DOWN, all_indexes, used_indexes)


func PrepFirstSelectionBoxDraw(group : NavMapGroup, direction_index : int, direction : Vector2, all_indexes : Array[int],  used_indexes : Array[int]):
	var element : Control = get_node_or_null(group.elements_to_map[direction_index])
	var found_count = HowManyTimesIndexInArray(used_indexes, direction_index)
	var total_count = HowManyTimesIndexInArray(all_indexes, direction_index)

	var selected_color : Color = Color.WHITE
	match visual_override != null:
		true:
			match direction:
				Vector2(0.0, -1.0):
					selected_color = visual_override.group_up_color
				Vector2(0.0, 1.0):
					selected_color = visual_override.group_down_color
				Vector2(-1.0, 0.0):
					selected_color = visual_override.group_left_color
				Vector2(1.0, 0.0):
					selected_color = visual_override.group_right_color
				_:
					selected_color = Color.RED
		false:
			match direction:
				Vector2(0.0, -1.0):
					selected_color = group_up_color
				Vector2(0.0, 1.0):
					selected_color = group_down_color
				Vector2(-1.0, 0.0):
					selected_color = group_left_color
				Vector2(1.0, 0.0):
					selected_color = group_right_color
				_:
					selected_color = Color.RED

	DrawNinePatchRect(element.global_position, element.size, GetSelectionBoxTexture(total_count, found_count), ModifyColorAlpha(ModifyColorAlpha(selected_color, 0.66), VisualOpacityValue()), 1, 1, RenderingServer.NinePatchAxisMode.NINE_PATCH_STRETCH)
	used_indexes.append(direction_index)


func GetSelectionBoxTexture(total_count : int, used_count : int):
	var used_box_tex : Texture2D = null
	match total_count:
		2:
			match used_count:
				0:
					used_box_tex = first_item_highlight_tex_right
				1:
					used_box_tex = first_item_highlight_tex_left
				_:
					used_box_tex = null
		3:
			match used_count:
				0:
					used_box_tex = first_item_highlight_tex_botright
				1:
					used_box_tex = first_item_highlight_tex_botleft
				2:
					used_box_tex = first_item_highlight_tex_top
				_:
					used_box_tex = null
		4:
			match used_count:
				0:
					used_box_tex = first_item_highlight_tex_botright
				1:
					used_box_tex = first_item_highlight_tex_botleft
				2:
					used_box_tex = first_item_highlight_tex_topright
				3:
					used_box_tex = first_item_highlight_tex_topleft
				_:
					used_box_tex = null
		_:
			used_box_tex = first_item_highlight_tex

	return used_box_tex


func HowManyTimesIndexInArray(int_array : Array[int], checked_index : int):
	var count : int = 0
	if (int_array.has(checked_index)):
		for i in int_array:
			if (i == checked_index):
				count += 1
	return count


func CheckStartMapping():
	if (mapping_queued):
		mapping_queued = false
		MapElements()


func _physics_process(delta):

	VisibilityToggle()

	if (Engine.is_editor_hint() && !disable_auto_update):
		if (check_frame < 2 and limit_update_frames):
			check_frame += 1
		else:
			check_frame = 0
			if AnyGroupsHaveEmpty(false):
				return
			else:
				MoveCheck()

		CheckStartMapping()


func VisibilityToggle():
	if (!Engine.is_editor_hint() && lock_visibility_toggle_at_runtime):
		return

	if Input.is_physical_key_pressed(alt_and_hotkey_to_hide) and Input.is_physical_key_pressed(KEY_ALT) and !visibility_input_lock:
		visibility_input_lock = true
		visible = !visible
	elif (!Input.is_physical_key_pressed(alt_and_hotkey_to_hide) && visibility_input_lock):
		visibility_input_lock = false


func MoveCheck():
	# check total count of elements
	var total_element_count = 0
	for g in element_groups.size():
		for e in element_groups[g].elements_to_map.size():
			if get_node_or_null(element_groups[g].elements_to_map[e]) == null:
				printerr("Element reference list broken at group " + str(g) + ", element " + str(e) +"!")
				return
			else:
				total_element_count += 1

	# if counts dont match, reset and rebuild reference
	if (element_positions.size() != total_element_count || element_sizes.size() != total_element_count):
		full_list_of_elements = []
		element_positions.clear()
		element_sizes.clear()
		for group in element_groups:
			for element_reference in group.elements_to_map:
				full_list_of_elements.append(get_node_or_null(element_reference))

		for node in full_list_of_elements:
			element_positions.append(node.global_position)
			element_sizes.append(node.size)
			pass

	# check full pile for changes
	for i in full_list_of_elements.size():
		if (element_positions[i] != full_list_of_elements[i].global_position || element_sizes[i] != full_list_of_elements[i].size):
			element_positions[i] = full_list_of_elements[i].global_position
			element_sizes[i] = full_list_of_elements[i].size
			QueueRemap()


enum NavigationReferenceErrorType {None, Invalid_path_on_deletion, Double_entry}
func TryCheckGenerateNavigationReference(force_reset):
	var error : NavigationReferenceErrorType = NavigationReferenceGeneration(force_reset)
	while (error == NavigationReferenceErrorType.Invalid_path_on_deletion):
		error = NavigationReferenceGeneration(true)
	return error == NavigationReferenceErrorType.None


func NavigationReferenceGeneration(force_reset):
	var full_element_count : int = 0
	for group in element_groups:
		full_element_count += group.elements_to_map.size()

	if (navigation_references.size() != full_element_count || force_reset):
		print("Resetting reference resources.")
		navigation_references.clear()
		for i in element_groups.size():

			# check for invalid / broken path entries, and remove
			var to_be_deleted_invalid_index : Array[int] = []
			for e in element_groups[i].elements_to_map.size():
				var current_selected_node = get_node_or_null(element_groups[i].elements_to_map[e])
				if (current_selected_node == null):
					printerr("Group " + str(i) + " element " + str(e) + " path invalid, and node couldn't be found. Removing entry.")
					to_be_deleted_invalid_index.append(e)

			if (to_be_deleted_invalid_index.size() > 0):
				# reverse so deletion starts from the newest to oldest instead of the other way
				to_be_deleted_invalid_index.reverse()
				for e in to_be_deleted_invalid_index.size():
					element_groups[i].RemoveFromElementListWithoutTriggering(to_be_deleted_invalid_index[e])
				return NavigationReferenceErrorType.Invalid_path_on_deletion

			for e in element_groups[i].elements_to_map.size():
				var added_node_name : String = get_node_or_null(element_groups[i].elements_to_map[e]).name
				if (navigation_references.has(added_node_name)):
					printerr("Reference dictionary already contains entry with key '" + added_node_name + "', please rename group " + str(i) + " element " + str(e) + " to with a unique name. Aborting mapping. (This may cause further errors until fixed)")
					return NavigationReferenceErrorType.Double_entry
				else:
					navigation_references.get_or_add(added_node_name, NavMapReference.new())

	var keys : Array[String] = GetNavRefDictionary()
	var full_index : int = 0
	for i in element_groups.size():
		for e in element_groups[i].elements_to_map.size():
			navigation_references[keys[full_index]].group_index = i
			navigation_references[keys[full_index]].parent_mapper = self
			full_index += 1

	return NavigationReferenceErrorType.None


func AnyGroupsHaveEmpty(can_force_warning : bool):
	var empty_found : bool = false
	var type_str : String = ""
	var warning_parent_index : int = -1
	for i in element_groups.size():

		if element_groups[i] == null or element_groups[i].elements_to_map.size() <= 0:
			empty_found = true
			warning_parent_index = i
			type_str = ""
			break

		else:
			for e in element_groups[i].elements_to_map.size():
				if (element_groups[i].elements_to_map[e] == NodePath("")):
					empty_found = true
					warning_parent_index = i
					type_str = ", child index " + str(e)
					break

	if (empty_found && (!empty_warning_printed || can_force_warning)):
		empty_warning_printed = true
		printerr("Empty found in container group index " + str(warning_parent_index) + type_str)
	if (!empty_found && empty_warning_printed):
		empty_warning_printed = false
	return empty_found


func MapElements():
	position = Vector2.ZERO
	DebugPrint("Starting navigation bake")
	if AnyGroupsHaveEmpty(true) == true:
		return

	# Rebuild custom path reference resources with group ID & origin references
	if update_type == AutoUpdateTypes.All:
		if (TryCheckGenerateNavigationReference(false) == false):
			return

	# element to element within group
	if update_type == AutoUpdateTypes.All:
		ElementNavigationMapping()
		pass
	elif update_type == AutoUpdateTypes.Visualization:
		MatchToManualAndAddArrows()
		pass

	# group to group, maps even with update set to only visualization
	GenerateGroupBoundingBoxes()
	GroupNavigationMapping()

	# add self to any empty built in focus reference to work around unwanted, unmapped navigation
	SelfToEmpty()
	SetFocusModeToMatchSetting()

	# Since there's currently no custom logic for next/previous
	# I'm simply disabling it for the time being to not break the idea of the groups too much
	DisableNextPrevious()

	queue_redraw()


func DisableNextPrevious():
	for i in navigation_references:
		var element : Control = get_node(navigation_references[i].origin)
		element.focus_next = NodePath("") if allow_base_godot_next_and_previous else NodePath(".")
		element.focus_previous = NodePath("") if allow_base_godot_next_and_previous else NodePath(".")


func SetFocusModeToMatchSetting():
	for i in navigation_references:
		get_node(navigation_references[i].origin).focus_mode = Control.FOCUS_ALL if allow_base_godot_focus  else Control.FOCUS_NONE


func MatchToManualAndAddArrows():
	var total_index : int = 0
	current_whole_index = 0
	var keys : Array[String] = GetNavRefDictionary()
	for group in element_groups:
		for e in group.elements_to_map.size():
			var node : Control = get_node(group.elements_to_map[e])
			node.focus_neighbor_top = NodePath("")
			node.focus_neighbor_bottom = NodePath("")
			node.focus_neighbor_left = NodePath("")
			node.focus_neighbor_right = NodePath("")
			CheckForOutOfGroupReference(total_index, group)
			ReApplyReferenceAndCalculateForAlreadyKnownTarget(node, keys[total_index])
			total_index += 1


func CheckForOutOfGroupReference(total_index : int, group : NavMapGroup):
	var keys : Array[String] = GetNavRefDictionary()
	for direction in directions:
		var checked_node : Control = get_node_or_null(GetNavReferencePath(direction, keys[total_index]))
		if checked_node == null:
			continue

		if !GroupContainsNode(checked_node, group.elements_to_map):
			navigation_references[keys[total_index]].SetDirectionReferences(direction, NodePath(""))


func GroupContainsNode(compared_node : Control, path_pile : Array[NodePath]):
	var is_found : bool = false
	for path in path_pile:
		if compared_node == get_node_or_null(path):
			is_found = true
			break
	return is_found


func ReApplyReferenceAndCalculateForAlreadyKnownTarget(current_origin_node : Control, key : String):
	for direction in directions:
		var target : Control = null
		match direction:
			Vector2(0.0, -1.0):
				target = get_node_or_null(navigation_references[key].up)
			Vector2(0.0, 1.0):
				target = get_node_or_null(navigation_references[key].down)
			Vector2(-1.0, 0.0):
				target = get_node_or_null(navigation_references[key].left)
			Vector2(1.0, 0.0):
				target = get_node_or_null(navigation_references[key].right)

		var origin_to_selected : NodePath = current_origin_node.get_path_to(target) if target != null else NodePath("")
		match direction:
			Vector2(0.0, -1.0):
				current_origin_node.focus_neighbor_top = origin_to_selected
			Vector2(0.0, 1.0):
				current_origin_node.focus_neighbor_bottom = origin_to_selected
			Vector2(-1.0, 0.0):
				current_origin_node.focus_neighbor_left = origin_to_selected
			Vector2(1.0, 0.0):
				current_origin_node.focus_neighbor_right = origin_to_selected


func CreateControlElementArray(group):
	var mappable : Array[Control] = []
	for element_path in group.elements_to_map:
		mappable.append(get_node(element_path))
	return mappable


func ElementNavigationMapping():
	current_whole_index = 0
	var keys : Array[String] = GetNavRefDictionary()

	for group in element_groups:
		var mappable_elements : Array[Control] = CreateControlElementArray(group)
		for element in mappable_elements:
			navigation_references[keys[current_whole_index]].origin = get_path_to(element)
			DebugPrint(keys[current_whole_index] + "-------------------------------------------")
			for direction in directions:

				DebugPrint(element.name + " " + PrintDirection(direction))

				ListAllViableTargetPoints(element, direction, mappable_elements)
				for i in point_positions.size():
					if (point_parents[i] == self):
						continue
					else:
						CalculateComparisonValues(element.global_position, element.size, point_positions[i], direction)

				SelectBestDirectionalCandidate()
				SetFinalReferences(element, direction, false, keys[current_whole_index])
				ClearDirectionalCheckListsAndValues()
				DebugPrint("-------------------------------------------")

			current_whole_index += 1
	

func GroupNavigationMapping():
	# group to group navigation
	for source_group in element_groups:
		source_group.ResetGroupDirectionalTargets()

		for direction in directions:
			current_whole_index = -1
			ListAllViableGroupTargetPoints(source_group, direction)
			for i in point_positions.size():
				if (group_point_parents[i] == source_group):
					continue
				else:
					CalculateComparisonValues(source_group.group_bounding_box_position, source_group.group_bounding_box_size, point_positions[i], direction)
			current_selected = SelectBestDirectionalGroupCandidate(source_group, direction)
			SetGroupFinalReference(source_group, direction)
			ClearDirectionalCheckListsAndValues()


func SelectBestDirectionalGroupCandidate(source_group : NavMapGroup, direction : Vector2):
	var current_best_control : Control = null
	var current_highest_weight : float = -9999999.0
	for point_index in point_positions.size():
		var cut_off_by_distance = distance_cut_off != -1 && distances[point_index] > distance_cut_off
		if (angles[point_index] > maximum_group_target_angle || cut_off_by_distance):
			continue
		else:
			if (finals[point_index] > current_highest_weight):
				current_highest_weight = finals[point_index]
				source_group.StoreGroupDirectionTarget(direction, GetIndexOfSelectedGroup(group_point_parents[point_index]))
				current_best_control = GetCorrectElementIndexFromGroup(group_point_parents[point_index], direction)

	return current_best_control


func SetGroupFinalReference(source_group : NavMapGroup, direction : Vector2):
	var keys : Array[String] = GetNavRefDictionary()
	for e in source_group.elements_to_map.size():

		# check which reference to start going up from from if index isnt set
		if (current_whole_index == -1):
			for p in navigation_references.size():
				if (MatchPathToPathViaNode(navigation_references[keys[p]].origin, source_group.elements_to_map[e])):
					current_whole_index = p
					break
		else:
			current_whole_index += 1

		# sets selected group to group nav target to each applicable of current source group
		SetFinalReferences(get_node(source_group.elements_to_map[e]), direction, true, keys[current_whole_index])


func GetIndexOfSelectedGroup(group : NavMapGroup):
	for i in element_groups.size():
		if (group == element_groups[i]):
			return i

	return -1


func SelfToEmpty():
	for group in element_groups:
		var mappable_elements : Array[Control] = CreateControlElementArray(group)
		for element in mappable_elements:
			for direction in directions:
				match direction:
					Vector2(0.0, -1.0):
						if (element.focus_neighbor_top == NodePath("")):
							element.focus_neighbor_top = "."

					Vector2(0.0, 1.0):
						if (element.focus_neighbor_bottom == NodePath("")):
							element.focus_neighbor_bottom = "."

					Vector2(-1.0, 0.0):
						if (element.focus_neighbor_left == NodePath("")):
							element.focus_neighbor_left = "."

					Vector2(1.0, 0.0):
						if (element.focus_neighbor_right == NodePath("")):
							element.focus_neighbor_right = "."


func MatchPathToPathViaNode(one, two):
	return get_node(one) == get_node(two)


func ClearDirectionalCheckListsAndValues():
	point_positions.clear()
	point_parents.clear()
	group_point_parents.clear()
	distances.clear()
	finals.clear()
	angles.clear()


func ListAllViableTargetPoints(current_origin_node : Control, direction : Vector2, mappable_elements : Array[Control]):
	for target_element in mappable_elements:
		if target_element == current_origin_node:
			continue
		else:
			var current_center : Vector2 = CalculateCenter(current_origin_node.global_position, current_origin_node.size)
			var target_center : Vector2 = CalculateCenter(target_element.global_position, target_element.size)
			if (CheckDirectionHit(direction, current_center, target_center) && !EdgeBeyondEdge(direction, current_origin_node.global_position, current_origin_node.size, target_element.global_position, target_element.size)):
				var generate_on_edge = CheckIfUseEdgeInsteadOfCenter(direction, current_origin_node.global_position, current_origin_node.size, target_element.global_position, target_element.size)
				AddNewPointsToLists(target_element.global_position, target_element.size, target_element, null, direction, generate_on_edge)


func ListAllViableGroupTargetPoints(source_group : NavMapGroup, direction : Vector2):
	for target_group in element_groups:
		if (source_group == target_group):
			continue

		var current_center : Vector2 = CalculateCenter(source_group.group_bounding_box_position, source_group.group_bounding_box_size)
		var target_center : Vector2 = CalculateCenter(target_group.group_bounding_box_position, target_group.group_bounding_box_size)
		if (CheckDirectionHit(direction, current_center, target_center) && !EdgeBeyondEdge(direction, source_group.group_bounding_box_position, source_group.group_bounding_box_size, target_group.group_bounding_box_position, target_group.group_bounding_box_size)):
			var generate_on_edge = CheckIfUseEdgeInsteadOfCenter(direction, source_group.group_bounding_box_position, source_group.group_bounding_box_size, target_group.group_bounding_box_position, target_group.group_bounding_box_size)
			AddNewPointsToLists(target_group.group_bounding_box_position, target_group.group_bounding_box_size, null, target_group, direction, generate_on_edge)


func AddNewPointsToLists(target_position : Vector2, target_size : Vector2, current_target_node : Control, current_target_group : NavMapGroup, direction : Vector2, generate_on_edge : bool):

	var vertical_approach_edge = Vector2.ZERO
	if (direction == Vector2.UP):
		vertical_approach_edge = Vector2(0, target_size.y)
	elif (direction == Vector2.DOWN):
		vertical_approach_edge = Vector2.ZERO

	var y_centering : Vector2 = Vector2(0.0, target_size.y / 2.0)
	var y_additive : Vector2 = Vector2(target_size.x / (check_resolution - 1.0), 0.0)

	var horizontal_approach_edge = Vector2.ZERO
	if (direction == Vector2.LEFT):
		vertical_approach_edge = Vector2(target_size.x, 0)
	elif (direction == Vector2.RIGHT):
		vertical_approach_edge = Vector2.ZERO

	var x_centering : Vector2 = Vector2(target_size.x / 2.0, 0.0)
	var x_additive : Vector2 = Vector2(0.0, target_size.y / (check_resolution - 1.0))

	for k in check_resolution:
		point_positions.append(CalculatePointPosition(target_position, k, direction, (vertical_approach_edge if generate_on_edge else y_centering), ( horizontal_approach_edge if generate_on_edge else x_centering), y_additive, x_additive))

		if (current_target_node != null):
			point_parents.append(current_target_node)
		elif (current_target_group != null):
			group_point_parents.append(current_target_group)


func CalculatePointPosition(point_pos : Vector2, index, direction : Vector2, y_centering : Vector2, x_centering : Vector2, y_additive : Vector2, x_additive : Vector2):
	var is_vertical : bool = abs(direction.y) == 1
	var centering : Vector2 = y_centering if is_vertical else x_centering
	var additive : Vector2 = y_additive if is_vertical else x_additive
	return point_pos + centering + (additive * index)


func GetCorrectElementIndexFromGroup(target_group : NavMapGroup, direction : Vector2):
	match direction:
		Vector2(0.0, -1.0):
			return get_node(target_group.elements_to_map[target_group.from_bottom_entry_selection_index])
		Vector2(0.0, 1.0):
			return get_node(target_group.elements_to_map[target_group.from_top_entry_selection_index])
		Vector2(-1.0, 0.0):
			return get_node(target_group.elements_to_map[target_group.from_right_entry_selection_index])
		Vector2(1.0, 0.0):
			return get_node(target_group.elements_to_map[target_group.from_left_entry_selection_index])
		_:
			return null


func CheckDirectionHit(direction : Vector2, current : Vector2, target : Vector2):
	match direction:
		Vector2(0.0, -1.0):
			return current.y > target.y
		Vector2(0.0, 1.0):
			return current.y < target.y
		Vector2(-1.0, 0.0):
			return  current.x > target.x
		Vector2(1.0, 0.0):
			return  current.x < target.x
		_:
			return false


func EdgeBeyondEdge(direction : Vector2, current_position : Vector2, current_size : Vector2, target_position : Vector2, target_size : Vector2):
	match direction:
		Vector2(0.0, -1.0):
			return current_position.y <= target_position.y
		Vector2(0.0, 1.0):
			return current_position.y + current_size.y >= target_position.y + target_size.y
		Vector2(-1.0, 0.0):
			return current_position.x <= target_position.x
		Vector2(1.0, 0.0):
			return current_position.x + current_size.x >= target_position.x + target_size.x
		_:
			return false


func OppositeEdgeBeyondEdge(direction : Vector2, current_position : Vector2, current_size : Vector2, target_position : Vector2, target_size : Vector2):
	match direction:
		Vector2(0.0, -1.0):
			return current_position.y <= target_position.y + target_size.y
		Vector2(0.0, 1.0):
			return current_position.y + current_size.y >= target_position.y
		Vector2(-1.0, 0.0):
			return current_position.x <= target_position.x + target_size.x
		Vector2(1.0, 0.0):
			return current_position.x + current_size.x >= target_position.x
		_:
			return false


func CheckIfUseEdgeInsteadOfCenter(direction : Vector2, current_position : Vector2, current_size : Vector2, target_position : Vector2, target_size : Vector2):
	match direction:
		Vector2(0.0, -1.0):
			return current_position.y > target_position.y + target_size.y
		Vector2(0.0, 1.0):
			return current_position.y + current_size.y < target_position.y
		Vector2(-1.0, 0.0):
			return current_position.x > target_position.x + target_size.x
		Vector2(1.0, 0.0):
			return current_position.x + current_size.x < target_position.x
		_:
			return false


func CalculateComparisonValues(origin_position : Vector2, origin_size : Vector2, point_pos : Vector2, direction : Vector2):
	var is_vertical = direction == Vector2.DOWN || direction == Vector2.UP
	var size_addition = Vector2(round(origin_size.x / (4 if use_left_bias else 2)), origin_size.y / 2.0) if is_vertical else origin_size / 2
	var calculated_center = origin_position + size_addition;
	var from_current_to_target = CalculateRelativeVector(point_pos, calculated_center)
	var dot_product = direction.dot(from_current_to_target.normalized())
	var distance = from_current_to_target.length()
	var angle = rad_to_deg(acos(dot_product))
	angles.append(angle)
	finals.append(pow(180.0 - angle, 3.0) / distance / 10000)
	distances.append(distance)


func SelectBestDirectionalCandidate():
	current_selected = null
	var current_highest_weight : float = 0.0

	for i in point_positions.size():
		var cut_off_by_distance = distance_cut_off != -1 && distances[i] > distance_cut_off
		if (angles[i] > maximum_target_angle || cut_off_by_distance):
			continue
		else:
			if (finals[i] > current_highest_weight || current_selected == null):
				current_highest_weight = finals[i]
				current_selected = point_parents[i]


func SetFinalReferences(current_origin_node : Control, direction : Vector2, for_group : bool, key : String):
	var origin_to_selected : NodePath = NodePath("") if current_selected == null else current_origin_node.get_path_to(current_selected)
	var this_to_selected : NodePath = NodePath("") if current_selected == null else get_path_to(current_selected)

	if (this_to_selected != NodePath("") && !for_group):
		DebugPrint("Final selected for " + current_origin_node.name + ": " + current_selected.name)

	match direction:
		Vector2(0.0, -1.0):
			if (!for_group || navigation_references[key].up == NodePath("")):
				navigation_references[key].SetDirectionReferences(direction, this_to_selected)
				current_origin_node.focus_neighbor_top = origin_to_selected

		Vector2(0.0, 1.0):
			if (!for_group || navigation_references[key].down == NodePath("")):
				navigation_references[key].SetDirectionReferences(direction, this_to_selected)
				current_origin_node.focus_neighbor_bottom = origin_to_selected

		Vector2(-1.0, 0.0):
			if (!for_group || navigation_references[key].left == NodePath("")):
				navigation_references[key].SetDirectionReferences(direction, this_to_selected)
				current_origin_node.focus_neighbor_left = origin_to_selected

		Vector2(1.0, 0.0):
			if (!for_group || navigation_references[key].right == NodePath("")):
				navigation_references[key].SetDirectionReferences(direction, this_to_selected)
				current_origin_node.focus_neighbor_right = origin_to_selected


func GetNavReferencePath(direction : Vector2, key : String):
	match direction:
		Vector2(0.0, -1.0):
			return navigation_references[key].up
		Vector2(0.0, 1.0):
			return navigation_references[key].down
		Vector2(-1.0, 0.0):
			return navigation_references[key].left
		Vector2(1.0, 0.0):
			return navigation_references[key].right
		_:
			return null


func PrintDirection(direction : Vector2):
	match direction:
		Vector2(0.0, -1.0):
			return "up"
		Vector2(0.0, 1.0):
			return "down"
		Vector2(-1.0, 0.0):
			return "left"
		Vector2(1.0, 0.0):
			return "right"
		_:
			return ""


func CalculateRelativeVector(to : Vector2, from : Vector2):
	return to - from


func CalculateCenter(pos : Vector2, size : Vector2):
	return pos + size / 2.0


func GetDirectionLetter(direction : Vector2):
	match direction:
		Vector2(0.0, -1.0):
			return "U"
		Vector2(0.0, 1.0):
			return "D"
		Vector2(-1.0, 0.0):
			return "L"
		Vector2(1.0, 0.0):
			return "R"


func DebugPrint(logMessage : String):
	if debug:
		print(logMessage)
	pass


func IsReadyToMap():
	return name != ""


func ModifyColorAlpha(original : Color, alpha : float):
	return Color(original.r, original.g, original.b, original.a * alpha)


func IsFullAutoUpdate():
	return update_type == AutoUpdateTypes.All


func RotateVectorWithAnother(rotator : Vector2, to_rotate : Vector2):
	var rotated_vector : Vector2 = Vector2((rotator.x * to_rotate.x) + (-rotator.y * to_rotate.y), (rotator.y * to_rotate.x) + (rotator.x * to_rotate.y))
	return Vector2(-rotated_vector.y, rotated_vector.x)


func VisualOpacityValue():
	return opacity / 100 if visual_override == null else visual_override.opacity / 100


func UsedScalingValue():
	return visuals_scaling_value if visual_override == null else visual_override.visuals_scaling_value
