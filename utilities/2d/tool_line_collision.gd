@tool
class_name ToolLineCollision
extends ToolLine

@export var target: RigidBody2D
@export var col: CollisionPolygon2D


func _ready() -> void:
	_update_points()


func _physics_process(_delta: float) -> void:
	col.global_transform = self.global_transform


func _update_points():
	super()
	if not col:
		col = CollisionPolygon2D.new()
		if target:
			target.add_child.call_deferred(col)
	col.polygon = points
