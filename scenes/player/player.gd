extends CharacterBody2D
class_name Player

@export_group("Nodes")
@export var grapple_cone: GrappleCone
@export var parry_hitbox: Area2D
@export var health_component: HealthComponent
@export var player_movement_component: PlayerMovementComponent
@export var respawn_delay: float = 0.2
@export var blood_drain: float = 15.0
@export var drink_amount: float = 20.0
@export var invincibilty_duration: float = 1.5
@export var flicker_duration: float = 1.0
var invincibility_counter: float = 0.0
var flicker_counter: float = 0.0

## Set the time the player is invincible for in seconds
func set_invincibility(time:float) -> void:
	if time > invincibility_counter:
		invincibility_counter = time

func _process(delta: float) -> void:
	if invincibility_counter > 0:
		invincibility_counter -= delta
	if flicker_counter > 0:
		flicker_counter -= delta
	var atk = Attack.new()
	atk.damage = blood_drain * delta
	health_component.damage(atk)
	#DEBUG
	#print(health_component.health)
	grapple_cone.look_at(get_global_mouse_position())

func drink():
	health_component.heal(drink_amount)

func spend_blood(required: float, cost: float):
	if health_component.health >= required:
		var atk = Attack.new()
		atk.damage = cost
		health_component.damage(atk)
		return true

## Checks if the player is invincible
func is_invincible() -> bool:
	return invincibility_counter > 0

func damage(atk:Attack) -> void:
	health_component.damage(atk)
	set_invincibility(invincibilty_duration)
	flicker_counter = flicker_duration

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
