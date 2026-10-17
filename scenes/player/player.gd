extends CharacterBody2D
class_name Player

@export_group("Nodes")
@export var grapple_cone: GrappleCone
@export var parry_hitbox: Area2D
@export var health_component: HealthComponent
@export var player_movement_component: PlayerMovementComponent
@export var respawn_delay: float = 0.2
@export var blood_drain: float = 10.0
var invinicibility_counter: float = 0.0

## Set the time the player is invincible for in seconds
func set_invincibility(time:float) -> void:
	invinicibility_counter = time

func _process(delta: float) -> void:
	if invinicibility_counter > 0:
		invinicibility_counter -= delta
	grapple_cone.look_at(get_global_mouse_position())

## Checks if the player is invincible
func is_invincible() -> bool:
	return invinicibility_counter > 0

func damage(atk:Attack) -> void:
	health_component.damage(atk)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player_ref = self
	health_component.death.connect(_on_death)

func _on_death() -> void:
	await get_tree().create_timer(respawn_delay).timeout
	_reload_level()
	
func _reload_level() -> void:
	get_tree().call_deferred("reload_current_scene")

func search_grapple_points(points: Array[GrapplePoint]) -> GrapplePoint:
	var grapple_point := grapple_cone.search_for_grapple_point(points)
	if grapple_point == null:
		SignalBus.highlight_enemy.emit(null)
		return
	var e = grapple_point.get_enemy()
	if e != null:
		SignalBus.highlight_enemy.emit(grapple_point.get_enemy())
	return grapple_point


func _physics_process(delta: float) -> void:
	player_movement_component.process_movement(self, delta)
