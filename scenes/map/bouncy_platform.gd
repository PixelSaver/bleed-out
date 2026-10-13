extends RigidBody2D

@export var bounce_power: float = 200


func _on_body_entered(body: Node) -> void:
	print("1")
	if body.is_in_group("Player"):
		print("2")
		if body.velocity.y >= 0:
			print("3")
			body.velocity.y = -1 * 100
