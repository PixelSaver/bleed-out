extends Area2D

## Checks that the player crosses this y level before moving.
@export var min_player_y: float = 800
@export var starting_speed: float = 100
@export var acceleration: float = 5
var speed = starting_speed
func _ready() -> void:
	self.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var atk = Attack.new()
		atk.damage = 100000000000.
		body.force_kill()
	elif body is Enemy and body is not EyeballEnemy:
		var atk = Attack.new()
		atk.damage = 100000000000
		body.damage(atk)
	elif body is not EyeballEnemy:
		body.queue_free()

func _process(delta: float) -> void:
	var p = Global.player_ref
	if not p: return
	if Global.player_ref.global_position.y > -min_player_y: 
		return
	if p.global_position.y >= self.global_position.y:
		p.force_kill()
	var dist = global_position.y - Global.player_ref.global_position.y 
	speed += acceleration * delta
	speed += (acceleration * delta) if dist > 800 else 0
	position.y += -1 * speed * delta
	Global.water_y = global_position.y
