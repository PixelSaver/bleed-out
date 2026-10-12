extends Area2D
@export var speed: float = 100

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body._on_death()

func _physics_process(delta: float) -> void:
	self.position += Vector2(0, -1 * speed * delta)
