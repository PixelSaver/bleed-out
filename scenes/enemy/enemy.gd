extends RigidBody2D
class_name Enemy

@export var grapple_point: GrapplePoint
@export var health_component: HealthComponent


func _ready() -> void:
	health_component.death.connect(_on_death)

func damage(atk:Attack) -> void:
	health_component.damage(atk)

func _on_death() -> void:
	pass

func get_grapple_point() -> GrapplePoint:
	return grapple_point if grapple_point else null

func highlight(do_highlight:bool) -> void:
	$ColorRect.color.a = 0.4 if do_highlight else 0.0
