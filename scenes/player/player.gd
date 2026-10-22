extends CharacterBody2D
class_name Player

@export_group("Nodes")
@export var grapple_cone: GrappleCone
@export var parry_hitbox: Area2D
@export var health_component: HealthComponent
@export var player_movement_component: PlayerMovementComponent
@export_category("Player tweaks")
@export var respawn_delay: float = 0.2
@export var blood_drain: float = -15.0
@export var drink_amount: float = 60.0
@export var drink_duration: float = 1.0
@export var invincibilty_duration: float = 1.5
@export var flicker_duration: float = 1.0
var blood_rate
var invincibility_counter: float = 0.0
var flicker_counter: float = 0.0
var using_mouse = false
var aim_dir = Vector2.UP
var is_dead := false;

## Set the time the player is invincible for in seconds
func set_invincibility(time:float) -> void:
	if time > invincibility_counter:
		invincibility_counter = time

func _process(delta: float) -> void:
	if invincibility_counter > 0:
		invincibility_counter -= delta
	if flicker_counter > 0:
		flicker_counter -= delta
	if blood_rate > blood_drain:
		blood_rate = move_toward(blood_rate, blood_drain, (drink_amount - blood_drain) / drink_duration * delta)
	if blood_rate > 0:
		health_component.heal(blood_rate * delta)
	else:
		var atk = Attack.new()
		atk.damage = -blood_rate * delta
		health_component.damage(atk)
	#DEBUG
	#print(health_component.health)
	if using_mouse:
		grapple_cone.look_at(get_global_mouse_position())
	else:
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if input_dir.length() > 0:
			grapple_cone.rotation = input_dir.angle()
	

func _input(event):
	if event is InputEventMouseMotion:
		using_mouse = true
	elif ["ui_up", "ui_down", "ui_left", "ui_right"].any(event.is_action_pressed):
		using_mouse = false

func drink():
	blood_rate = drink_amount

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
	if not is_invincible():
		health_component.damage(atk)
		set_invincibility(invincibilty_duration)
		flicker_counter = flicker_duration
		player_movement_component.let_go(self)
		var sound = [
			AudioManager.Sound.HURT_1, 
			AudioManager.Sound.HURT_2,
			AudioManager.Sound.HURT_3,
		].pick_random()
		AudioManager.play_sfx(sound, -20)

## Kills player regardless of invincibility
func force_kill() -> void:
	health_component.health = 0.

func _enter_tree() -> void:
	Global.player_ref = self
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.player_ref = self
	health_component.death.connect(_on_death)
	blood_rate = blood_drain
	self.health_component.health_changed.connect(_on_health)
	$LowHealth.playing = true
	$LowHealth.stream_paused = true

func _on_health(h:float, mh:float) -> void:
	if mh == 0: return
	var low_health := (h / mh) < 0.1
	if low_health and $LowHealth.stream_paused == true:
		$LowHealth.stream_paused = false
	elif not low_health and not $LowHealth.stream_paused:
		$LowHealth.stream_paused = true


func _on_death() -> void:
	if is_dead:
		return
	var sound = [AudioManager.Sound.DEATH].pick_random()
	AudioManager.play_sfx(sound, -20)
	is_dead = true
	SignalBus.died.emit()
	
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
