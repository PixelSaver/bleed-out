@tool
extends Resource

class_name NavMapReference
var parent_mapper : Node

@export var Left : NodePath:
	get:
		return left
	set(value):
		left = value
		if parent_mapper != null:
			parent_mapper.QueueOnlyManualUpdate("left")
var left : NodePath

@export var Up : NodePath:
	get:
		return up
	set(value):
		up = value
		if parent_mapper != null:
			parent_mapper.QueueOnlyManualUpdate("up")
var up : NodePath

@export var Right : NodePath:
	get:
		return right
	set(value):
		right = value
		if parent_mapper != null:
			parent_mapper.QueueOnlyManualUpdate("right")
var right : NodePath

@export var Down : NodePath:
	get:
		return down
	set(value):
		down = value
		if parent_mapper != null:
			parent_mapper.QueueOnlyManualUpdate("down")
var down : NodePath

@export_group("Self-reference")
@export var group_index : int
@export var origin : NodePath

func SetDirectionReferences(direction : Vector2, path_to_target : NodePath):
	match direction:
		Vector2(0.0, -1.0):
			up = path_to_target
			pass
		Vector2(0.0, 1.0):
			down = path_to_target
			pass
		Vector2(-1.0, 0.0):
			left = path_to_target
			pass
		Vector2(1.0, 0.0):
			right = path_to_target
			pass
	pass
