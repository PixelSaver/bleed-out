extends Area2D

@export var starting_speed: float = 100
@export var acceleration: float = 5
var speed = starting_speed

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body._on_death()

func _process(delta: float) -> void:
	speed += acceleration * delta
	position.y += -1 * speed * delta
