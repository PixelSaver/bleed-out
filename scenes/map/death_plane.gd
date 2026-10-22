extends Area2D

## Checks that the player crosses this y level before moving.
@export var min_player_y: float = 1000
@export var starting_speed: float = 100.0
@export var max_speed: float = 500.0
## Steepness of the acceleration sigmoid curve
@export var k: float = 0.06
## Controls how much buildup there is to the acceleration
@export var h: float = 3.0
@export var rubberband_threshold: float = 1000.0
@export var rubberband_speed: float = 1.0

var elapsed_time: float = 0.0

func get_speed(t: float) -> float:
	var e = exp(k * t)
	return starting_speed + (max_speed - starting_speed) * (e - 1.0) / (e + exp(h))

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
	
	elapsed_time += delta
	var rubberband_boost = maxf(global_position.y - p.global_position.y - rubberband_threshold, 0.0) * rubberband_speed
	var speed = get_speed(elapsed_time) + rubberband_boost
	print("Base: ", get_speed(elapsed_time),
	" | Distance: ", global_position.y - p.global_position.y,
	" | Boost: ", rubberband_boost,
	" | Total: ", speed)
	position.y -= speed * delta
	
	Global.water_y = global_position.y
