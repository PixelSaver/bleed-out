extends Area2D

@export var starting_speed: float = 100
@export var acceleration: float = 5
var speed = starting_speed

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body._on_death()

func _physics_process(delta: float) -> void:
	speed += acceleration * delta
	self.position += Vector2(0, -1 * speed * delta)
