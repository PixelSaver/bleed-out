extends Area2D

@export var starting_speed: float = 100
@export var acceleration: float = 5
var speed = starting_speed

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var atk = Attack.new()
		atk.damage = 100000000000
		body.damage(atk)
	if body is Enemy:
		var atk = Attack.new()
		atk.damage = 100000000000
		body.damage(atk)

func _process(delta: float) -> void:
	var dist = global_position.y - Global.player_ref.global_position.y 
	speed += acceleration * delta
	speed += (acceleration * delta) if dist > 800 else 0
	position.y += -1 * speed * delta
	
