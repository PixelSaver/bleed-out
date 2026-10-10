@tool
extends Container

## Osu-like container to scroll through options
class_name RadialContainer

signal selected_item_changed(idx: int)

var _current_selected_idx := -1
var _last_scrolled_angle : float = INF

@export var radius := 100.0:
	set(val):
		radius = val
		queue_sort()
		if Engine.is_editor_hint():
			_update_children()
@export var separation := 10.0:
	set(val):
		separation = val
		queue_sort()
		if Engine.is_editor_hint():
			_update_children()
@export var circle_center := Vector2(100.0, 0):
	set(val):
		circle_center = val
		queue_sort()
		if Engine.is_editor_hint():
			_update_children()
@export var flip := false:
	set(val):
		flip = val
		queue_sort()
		if Engine.is_editor_hint():
			_update_children()
@export var target_scroll_angle := 0.0:
	set(val):
		target_scroll_angle = val
		queue_sort()
		if Engine.is_editor_hint():
			_update_children()
@export var visibility_window := 15 :
	set(val):
		visibility_window = val
		queue_sort()
		if Engine.is_editor_hint():
			_update_children()
@export var scroll_active := true :
	set(val):
		scroll_active = val
		if Engine.is_editor_hint():
			_update_children()
@export var drag_sensitivity := 0.005
@export_range(0.0, 1.0) var scroll_accel := 1.0
## Proportion taken off the scale of neighboring children.
## Children farther away from current angle are this much smaller
@export var scale_multiplier := 0.1
@export var scroll_bar: VScrollBar
@export_category("Container Exclusion")
@export var excluded: Array[Node] = []
@export var max_lerp_cooldown := 0.6
var current_children: Array[Control] = []
var scroll_angle := 0.0
var _previous_start: int = INT32_MAX
var _previous_end: int = INT32_MIN
var _lerp_cooldown: float

# Dragging
var _dragging := false
var _last_mouse_pos := Vector2.ZERO

func _enter_tree() -> void:
	if !scroll_bar: 
		scroll_bar = VScrollBar.new()
		add_child(scroll_bar)
		excluded.append(scroll_bar)
	scroll_bar.z_index = 100

func _ready() -> void:
	self.scroll_angle = 0
	self.target_scroll_angle = self.scroll_angle
	_lerp_cooldown = max_lerp_cooldown
	scroll_bar.scrolling.connect(func():
		self.scroll_to_index(int(scroll_bar.value))
	)
	self.child_entered_tree.connect(func(node:Node):
		if node is not Control: return
		if excluded.has(node): return
		current_children.append(node)
		move_child(scroll_bar, get_child_count() - 1)
		selected_item_changed.emit(get_closest_idx())
	)
	self.child_exiting_tree.connect(func(node:Node):
		if current_children.has(node): 
			current_children.erase(node)
		selected_item_changed.emit(get_closest_idx())
	)
	for child in get_children():
		if not child is Control: continue
		if excluded.has(child): continue
		child.visible = false
		current_children.append(child)

func _update_scrollbar():
	if scroll_bar == null or Engine.is_editor_hint():
		return
	var count := _get_layout_children().size()
	scroll_bar.visible = count > visibility_window
	if !scroll_bar.visible:
		return
	scroll_bar.min_value = 0
	scroll_bar.max_value = max(0, count - 1)
	scroll_bar.page = visibility_window
	scroll_bar.set_value_no_signal(get_closest_idx())

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_update_children()

func _get_layout_children() -> Array[Control]:
	return current_children
	#var result: Array[Control] = []
	#for child in get_children():
		#if not child is Control:
			#continue
		#if excluded.has(child):
			#continue
		#result.append(child)
	#return result


func _process(delta: float) -> void:
	var children = _get_layout_children()
	if children.size() <= 1:
		return

	var min_limit = -(children.size() - 1) * get_theta()
	var max_limit = 0.0

	var is_overshooting = target_scroll_angle > max_limit or target_scroll_angle < min_limit

	if is_overshooting:
		var target = clampf(target_scroll_angle, min_limit, max_limit)
		target_scroll_angle = lerpf(target_scroll_angle, target, delta * 10.0)

	scroll_angle = lerpf(scroll_angle, target_scroll_angle, delta * 5.0)
	if !(abs(scroll_angle - _last_scrolled_angle) < .000001) or !(abs(target_scroll_angle - scroll_angle) < .00001):
		_update_children(children)
		_update_scrollbar()
	var idx := get_closest_idx()
	if idx != _current_selected_idx:
		_current_selected_idx = idx
		selected_item_changed.emit(idx)
		
	if Engine.is_editor_hint(): return
	_lerp_cooldown -= delta
	if _lerp_cooldown < 0.0:
		lerp_to_closest()
	_last_scrolled_angle = scroll_angle


## Angle separation between two children
func get_theta() -> float:
	return 2.0 * asin(separation / (2.0 * radius))


func get_closest_position() -> Vector2:
	var children = _get_layout_children()
	if children.is_empty():
		return global_position

	var theta = get_theta()
	var idx = get_closest_idx()

	var angle = scroll_angle + (idx * theta)
	if flip:
		angle = PI - angle

	var center = circle_center + size * Vector2(0.0, 0.5)
	center = get_global_transform() * get_actual_center()
	return center + Vector2(cos(angle), sin(angle)) * radius


func scroll_to_index(idx: int):
	var children = _get_layout_children()
	idx = clamp(idx, 0, children.size() - 1)
	target_scroll_angle = -idx * get_theta()


func scroll_to_child(child: Control):
	var children = _get_layout_children()
	var idx := children.find(child)
	if idx != -1:
		scroll_to_index(idx)
		_on_scrolled()


func get_closest_idx() -> int:
	var theta = get_theta()
	var children = _get_layout_children()
	if children.is_empty():
		return -1

	var idx = round(-(scroll_angle) / theta)
	idx = clampi(idx, 0, children.size() - 1)
	return idx


func lerp_to_closest():
	var theta = get_theta()
	var children = _get_layout_children()
	if children.is_empty():
		return

	var idx = round(-scroll_angle / theta)
	idx = clampi(idx, 0, children.size() - 1)

	var snap = -idx * theta
	target_scroll_angle = lerpf(target_scroll_angle, snap, 0.03)


func _update_children(children:Array[Control]=[]):
	if children.size() == 0: children = _get_layout_children()
	if children.size() == 0: return
	if scroll_bar:
		var width := 12.0
		scroll_bar.position = Vector2(size.x - width, 0)
		scroll_bar.size = Vector2(width, size.y)
	
	var theta = get_theta()
	var center = get_actual_center()
	
	var closest_idx = get_closest_idx()
	if closest_idx == -1: return
	var start = max(closest_idx - visibility_window, 0)
	var end = min(closest_idx + visibility_window, children.size())
	
	var window_start = max(min(start, _previous_start), 0)
	var window_end = min(max(end, _previous_end), children.size())
	_previous_start = start
	_previous_end = end
	
	for i in range(window_start, window_end):
		children[i].visible = (start <= i && i < end)
	
	for i in range(start, end):
		var child = children[i]
		var current_angle = scroll_angle + (i * theta)
		# Distance from selected idx# angular distance from center
		var angle_dist = abs(current_angle)
		if flip:
			current_angle = PI - current_angle
		var pos = center + Vector2(cos(current_angle), sin(current_angle)) * radius

		var dist = angle_dist / theta
		var _scale = pow(1.0 / (1.0 + dist * scale_multiplier), 1.5)
		#child.pivot_offset_ratio = Vector2(0.0, 0.5) if not flip else Vector2(1.0, 0.5)
		child.pivot_offset_ratio = Vector2(0.0, 0.5) if flip else Vector2(1.0, 0.5)
		var child_size = child.get_combined_minimum_size()
		fit_child_in_rect(child, Rect2(pos - (child_size / 2.0), child_size))
		child.scale = Vector2(_scale, _scale)


func _gui_input(event: InputEvent) -> void:
	var scroll_strength = 0.05
	var boost = clampf(exp(1.5*scroll_accel*abs(target_scroll_angle - scroll_angle)), 1, 5)
	if target_scroll_angle > 0 or target_scroll_angle < -(_get_layout_children().size() - 1) * get_theta():
		scroll_strength = 0.025
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_dragging = true
				_last_mouse_pos = event.position
				_on_scrolled()
			else:
				_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		var delta: Vector2 = event.relative
		_last_mouse_pos = event.position

		#TODO Generalize to x and y if exporting this
		target_scroll_angle += delta.y * drag_sensitivity * boost
		_on_scrolled()

	if event.is_action_pressed("scroll_up"):
		target_scroll_angle += scroll_strength * boost
		_on_scrolled()
	elif event.is_action_pressed("scroll_down"):
		target_scroll_angle -= scroll_strength * boost
		_on_scrolled()


func _on_scrolled():
	_lerp_cooldown = max_lerp_cooldown


func get_actual_center() -> Vector2:
	var center = circle_center + (size * Vector2(0.0, 0.5))
	if flip:
		center.x = size.x - circle_center.x
	return center


func get_current_child() -> Node:
	return _get_layout_children()[get_closest_idx()]
