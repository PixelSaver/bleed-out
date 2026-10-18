extends Enemy
class_name EyeballEnemy

## Time in seconds between ghost lazer and actual shot
@export var lazer_delay: float = 3.
@export var pupil: Sprite2D
@export var lazer_area: Area2D
## The line that shows player where it's going to shoot.
@export var lazer_line_promise: Line2D
@export var lazer_line: Line2D
var t : Tween

## Spawns a ghost lazer for where it would be shooting, have it follow the player around, and then shoot
## after a short delay.
func lazer(p_ref: Player) -> void:
	# spawn ghost lazer
	if t and t.is_running(): t.kill()
	lazer_line.width = 0.0
	lazer_line_promise.width = 0.0
	lazer_line_promise.modulate.a = 0.0
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_property(lazer_line_promise, "width", 10., lazer_delay)
	t.tween_property(lazer_line_promise, "modulate:a", 0.3, lazer_delay/2.)
	t.chain()
	t.tween_interval(0.5)
	t.chain()
	# fire lazer
	t.tween_property(lazer_line, "width", 10., 0.1)
	t.chain()
	t.tween_callback(func() -> void:
		
	)
	# Have an area2d check for collisions when the lazer fires, and apply atk to any player colliders
	var _atk = Attack.new()
	_atk.damage = 1.0
	pass

## Look at a positoin using the eye, global position
func eye_look(pos: Vector2, delta: float) -> void:
	var dir : Vector2 = pos - self.global_position
	dir = dir.normalized()
	var angle = dir.angle()
	dir *= Vector2(15, 10)
	pupil.position = pupil.position.lerp(dir, delta * 15)
	lazer_area.global_rotation = lerp_angle(lazer_area.global_rotation, angle, delta * 15)
	
func _process(delta: float) -> void:
	eye_look(get_global_mouse_position(), delta)
	if Input.is_action_just_pressed("debug"):
		print("Shooting lazer")
		lazer(null)

func _on_death() -> void:
	pass

@onready var marked: AnimatedSprite2D = $Marked
var is_highlighted = false
func highlight(do_highlight:bool) -> void:
	if do_highlight and not is_highlighted:
		is_highlighted = true
		marked.set_frame(0)
		marked.play("default", 1.)
	elif do_highlight == false and is_highlighted == true:
		is_highlighted = false
		marked.set_frame(0)
		marked.play("default", -2., true)
