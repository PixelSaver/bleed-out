extends Control

@export var player_pos: Node2D
@export var sword_pos: Sprite2D
@export var noise: FastNoiseLite
var time := 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	player_pos.position.x = noise.get_noise_2d(time, -10.) * 50
	player_pos.position.y = noise.get_noise_2d(time, 100.) * 50
	sword_pos.position.x = noise.get_noise_2d(time, 300) * 20
	sword_pos.position.y = noise.get_noise_2d(time, 400.) * 20
