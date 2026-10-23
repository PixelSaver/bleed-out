@tool
extends Resource
class_name NavMapGroup
var parent_mapper : Control

## Array of all elements considered part of this group and used for mapping navigation
@export var ElementsToMap : Array[NodePath]:
	get:
		return elements_to_map
	set(value):
		if (parent_mapper == null):
			elements_to_map = value
			return
		else:
			if (!parent_mapper.IsFullAutoUpdate()):
				printerr(parent_mapper.name + " update mode set to visualization only, cannot modify element list.")
				return

			var new_is_larger : bool = elements_to_map.size() < value.size()
			elements_to_map = value
			CheckEntryIndexLimits()
			if (new_is_larger):
				parent_mapper.QueueRemap()
			else:
				if (parent_mapper.TryCheckGenerateNavigationReference(true)):
					parent_mapper.QueueRemap()
var elements_to_map : Array[NodePath]

@export_group("Entry selection indexes")
## Index of element selected when group is entered from another group from above this group
@export var FromTopEntrySelectionIndex : int:
	get:
		return from_top_entry_selection_index
	set(value):
		from_top_entry_selection_index = value
		CheckEntryIndexLimits()
var from_top_entry_selection_index : int

## Index of element selected when group is entered from another group from the left of this group
@export var FromLeftEntrySelectionIndex : int:
	get:
		return from_left_entry_selection_index
	set(value):
		from_left_entry_selection_index = value
		CheckEntryIndexLimits()
var from_left_entry_selection_index : int

## Index of element selected when group is entered from another group from the right of this group
@export var FromRightEntrySelectionIndex : int:
	get:
		return from_right_entry_selection_index
	set(value):
		from_right_entry_selection_index = value
		CheckEntryIndexLimits()
var from_right_entry_selection_index : int

## Index of element selected when group is entered from another group from below this group
@export var FromBottomEntrySelectionIndex : int:
	get:
		return from_bottom_entry_selection_index
	set(value):
		from_bottom_entry_selection_index = value
		CheckEntryIndexLimits()
var from_bottom_entry_selection_index : int

@export_group("Reference values")
## Virtual 'position' of this group's container box used for group-to-group calculations
@export var group_bounding_box_position : Vector2
## Virtual 'size' of this group's container box used for group-to-group calculations
@export var group_bounding_box_size : Vector2
## stored group index of group-to-group target when moving up (-1 is null)
@export var direction_group_target_index_up : int = -1
## stored group index of group-to-group target when moving left (-1 is null)
@export var direction_group_target_index_left : int = -1
## stored group index of group-to-group target when moving right (-1 is null)
@export var direction_group_target_index_right : int = -1
## stored group index of group-to-group target when moving down (-1 is null)
@export var direction_group_target_index_down : int = -1

func CheckEntryIndexLimits():
	if (elements_to_map.size() > 0):
		from_top_entry_selection_index = clamp(from_top_entry_selection_index, 0, elements_to_map.size()-1)
		from_left_entry_selection_index = clamp(from_left_entry_selection_index, 0, elements_to_map.size()-1)
		from_right_entry_selection_index = clamp(from_right_entry_selection_index, 0, elements_to_map.size()-1)
		from_bottom_entry_selection_index = clamp(from_bottom_entry_selection_index, 0, elements_to_map.size()-1)
		if parent_mapper != null:
			parent_mapper.QueueRemap()

func RemoveFromElementListWithoutTriggering(target_index):
	elements_to_map.remove_at(target_index)

func StoreGroupDirectionTarget(direction, target_group_index):
	match direction:
		Vector2(0.0, -1.0):
			direction_group_target_index_up = target_group_index
		Vector2(0.0, 1.0):
			direction_group_target_index_down = target_group_index
		Vector2(-1.0, 0.0):
			direction_group_target_index_left = target_group_index
		Vector2(1.0, 0.0):
			direction_group_target_index_right = target_group_index

func ResetGroupDirectionalTargets():
	direction_group_target_index_up = -1
	direction_group_target_index_down = -1
	direction_group_target_index_left = -1
	direction_group_target_index_right = -1
