extends Enemy
class_name EyeballEnemy

## Time in seconds between ghost lazer and actual shot
@export var tracking_time: float = 2
@export var tracking_opacity: float = 0.5
@export var fire_delay: float = 0.5
@export var despawn_time: float = 0.3
@export var force_multiplier = 60
@export var hover_radius = 50

@onready var laser_line: Line2D = $Line2D
@onready var laser_hitbox: Area2D = $Area2D

var player_tracking: bool = false
var laser_length = 2000

func _on_fire_cycle_timer_timeout() -> void:
	start_attack_sequence()

func _process(delta: float) -> void:
	var direction: Vector2 = (Global.player_ref.position - position).normalized()
	var distance: float = (Global.player_ref.position - position).length()
	var target: Vector2 = direction * (distance - hover_radius)
	var tangent = target.tangent().normalized
	apply_force(target * force_multiplier)
	
	if player_tracking:
		
		direction = direction.normalized()
		laser_line.set_point_position(1, direction * laser_length)
		laser_hitbox.rotation = direction.angle()

## Spawns a ghost lazer for where it would be shooting, have it follow the player around, and then shoot
## after a short delay.
func start_attack_sequence() -> void:
	# spawn ghost lazer
	laser_line.default_color.a = tracking_opacity
	laser_line.visible = true
	player_tracking = true
	# have ghost lazer follow player around
	await get_tree().create_timer(tracking_time).timeout
	# laser stops tracking the player
	player_tracking = false
	await get_tree().create_timer(fire_delay).timeout
	# fire lazer
	laser_line.default_color.a = 1
	await get_tree().create_timer(despawn_time).timeout
	laser_line.visible = false
	# Have an area2d check for collisions when the lazer fires, and apply atk to any player colliders
	# TODO: set up laser_hitbox with the attack
	var _atk = Attack.new()
	_atk.damage = 1.0
	pass

func _input(event: InputEvent) -> void:
	if not OS.is_debug_build(): return
	if event.is_action_pressed("debug"):
		start_attack_sequence()

func _on_death() -> void:
	pass

func highlight(do_highlight:bool) -> void:
	super(do_highlight)
	pass
