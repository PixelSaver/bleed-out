
extends Enemy
class_name EyeballEnemy

@export_group("Nodes")
@export var pupil: Sprite2D
@export var shoot_range: Area2D
@export var eye_background: AnimatedSprite2D
@export var back_rect: ColorRect
@export var front_rect: ColorRect
@export var lazer_area: Area2D
## The line that shows player where it's going to shoot.
@export var lazer_line_promise: Line2D
@export var lazer_line: Line2D
@export_category("Eyeball")
@export var lazer_damage: float = 15.
## Time in seconds between ghost lazer and actual shot
@export var lazer_delay: float = 1.
@export var lazer_cooldown: float = .1
@export var hold_aim_duration: float = 0.2
@export var approach_speed: float = 10000.0
@export var orbit_speed: float = 10000.0
@export var water_buffer: float = 250.0
@export var water_avoid_speed: float = 1000.0
## If the eye is following player position
var is_following: bool = false
var can_shoot_player: bool = false
var _lazer_cooldown: float = 0.0
var t : Tween
var _random_pupil_target: Vector2 = Vector2.ZERO
var _random_pupil_timer: float = 0.0
var orbit_dir = 1

func _ready() -> void:
	super()
	shoot_range.body_entered.connect(_on_body_entered)
	shoot_range.body_exited.connect(_on_body_exited)
	_random_pupil_target = pupil.position
	# Randomize orbit direction between clockwise and counterclockwise
	orbit_dir *= randi_range(0, 1) * 2 - 1
	health_component.health_changed.connect(_on_health_changed)

func set_rings(n: int) -> void:
	var thickness := Vector3.ONE * .05
	var eye_counts := Vector3i(9, 12, 16)
	n = clampi(n, 0, 3)
	var bm = (back_rect.material as ShaderMaterial)
	var fm = (front_rect.material as ShaderMaterial)
	if n == 3:
		bm.set_shader_parameter("ring_thickness", thickness)
		bm.set_shader_parameter("eye_counts", eye_counts)
		fm.set_shader_parameter("ring_thickness", thickness)
		fm.set_shader_parameter("eye_counts", eye_counts)
	elif n == 2:
		bm.set_shader_parameter("ring_thickness", Vector3(thickness.x, thickness.y, -1.))
		fm.set_shader_parameter("ring_thickness", Vector3(thickness.x, thickness.y, -1.))
	elif n == 1:
		bm.set_shader_parameter("ring_thickness", Vector3(thickness.x, -1., -1.))
		bm.set_shader_parameter("eye_counts", Vector3i(eye_counts.x, 0, 0))
		fm.set_shader_parameter("ring_thickness", Vector3(thickness.x, -1., -1.))
		fm.set_shader_parameter("eye_counts", Vector3i(eye_counts.x, 0, 0))
	elif n == 0:
		bm.set_shader_parameter("ring_thickness", Vector3(-1., -1., -1.))
		bm.set_shader_parameter("eye_counts", Vector3i(0, 0, 0))
		fm.set_shader_parameter("ring_thickness", Vector3(-1., -1., -1.))
		fm.set_shader_parameter("eye_counts", Vector3i(0, 0, 0))



func _on_health_changed(h: float, _mh:float) -> void:
	if h > 0:
		AudioManager.play_sfx(AudioManager.Sound.EYEBALL_SHIELD_BREAK, -20)
	set_rings(int(h))

func _on_body_entered(body: Node2D) -> void:
	if body is not Player: return
	var p = body as Player
	if p == null: return
	can_shoot_player = true
	try_lazer_again()

func _on_body_exited(body: Node2D) -> void:
	if body is not Player: return
	var p = body as Player
	if p == null: return
	can_shoot_player = false

## Spawns a ghost lazer for where it would be shooting, have it follow the player around, and then shoot
## after a short delay.
func lazer() -> void:
	# spawn ghost lazer
	if t and t.is_running(): return
	is_following = true
	lazer_line.width = 0.0
	lazer_line_promise.width = 0.0
	lazer_line_promise.modulate.a = 0.0
	eye_background.pause()
	eye_background.set_frame_and_progress(0, 0.)
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_QUINT).set_parallel(true)
	t.tween_callback(func():
		var sound = [
			AudioManager.Sound.LAZER_CHARGE, 
		].pick_random()
		AudioManager.play_sfx(sound, -20)
	)
	t.tween_property(lazer_line_promise, "width", 15., lazer_delay)
	t.tween_property(lazer_line_promise, "modulate:a", 0.3, lazer_delay/2.)
	t.tween_callback(func(): eye_background.set_frame_and_progress(1, 0.))
	t.tween_callback(func(): eye_background.set_frame_and_progress(2, 0.)).set_delay(lazer_delay*2/3.)
	t.set_ease(Tween.EASE_IN)
	t.tween_property(lazer_line, "width", 1., lazer_delay)
	t.set_ease(Tween.EASE_OUT)
	t.chain()
	t.tween_interval(0.3)
	t.chain()
	t.tween_callback(func():
		is_following = false
	)
	t.tween_interval(hold_aim_duration)
	t.chain()
	# fire lazer
	t.tween_property(lazer_line, "width", 15., 0.3)
	t.tween_callback(func() -> void:
		var sound = [
			AudioManager.Sound.LAZER_FIRE, 
		].pick_random()
		AudioManager.play_sfx(sound, -20)
		if lazer_area.has_overlapping_bodies():
			for body in lazer_area.get_overlapping_bodies():
				if body is Player:
					var p = body as Player
					var atk = Attack.new()
					atk.damage = lazer_damage
					p.damage(atk)
	).set_delay(0.15)
	t.chain()
	t.tween_property(lazer_line, "width", 0., 0.4)
	t.tween_property(lazer_line_promise, "width", 0., 0.7)
	t.chain()
	t.tween_callback(func() -> void:
		is_following = true
		_lazer_cooldown = lazer_cooldown
		eye_background.play("red", -1, true)
	)

## Look at a positoin using the eye, global position
func eye_look(pos: Vector2, delta: float) -> void:
	var dir : Vector2 = pos - self.global_position
	dir = dir.normalized()
	var angle = dir.angle()
	dir *= Vector2(15, 10)
	var target = pupil.position.lerp(dir, delta * 15)
	pupil.position = target
	dir = dir.normalized() * 0.8
	(back_rect.material as ShaderMaterial).set_shader_parameter(
		"look_direction", 
		Vector3(dir.x, dir.y, -1.)
	)
	(front_rect.material as ShaderMaterial).set_shader_parameter(
		"look_direction", 
		Vector3(dir.x, dir.y, -1.)
	)
	lazer_area.global_rotation = lerp_angle(lazer_area.global_rotation, angle, delta * 15)

func try_lazer_again() -> void:
	if _lazer_cooldown > 0: return
	if shoot_range.has_overlapping_bodies():
		for body in shoot_range.get_overlapping_bodies():
			if body is Player:
				lazer()
	
func _process(delta: float) -> void:
	if not t or not t.is_running():
		is_following = can_shoot_player
	
	if _lazer_cooldown >= 0:
		_lazer_cooldown -= delta
		if _lazer_cooldown <= 0:
			try_lazer_again()
	
	if is_following:
		eye_look(Global.player_ref.global_position + Global.player_ref.velocity * 0.05, delta)
		(back_rect.material as ShaderMaterial).set_shader_parameter(
			"random_look", 
			false
		)
		(front_rect.material as ShaderMaterial).set_shader_parameter(
			"random_look", 
			false
		)
	else:
		(back_rect.material as ShaderMaterial).set_shader_parameter(
			"random_look", 
			true
		)
		(front_rect.material as ShaderMaterial).set_shader_parameter(
			"random_look", 
			true
		)
		_random_pupil_timer -= delta
		if _random_pupil_timer <= 0.0:
			_random_pupil_target = Vector2(
				randf_range(-15.0, 15.0),
				randf_range(-10.0, 10.0)
			)
			_random_pupil_timer = randf_range(0.3, 1.2)
		pupil.position = pupil.position.lerp(
			_random_pupil_target,
			delta * 3.0
		)
	#if Input.is_action_just_pressed("debug"):
		#print("Shooting lazer")
		#lazer()

func _physics_process(_delta: float) -> void:
	if not Global.player_ref: return
	var below = self.global_position.y - Global.player_ref.global_position.y  > 800
	var offset = Global.player_ref.global_position - self.global_position
	var distance = offset.length()
	var dir = offset.normalized()
	var tan_dir = Vector2(dir.y, -dir.x) * orbit_dir

	if distance > 1000.0:
		self.apply_central_force(dir * approach_speed * (10. if below else 1.))
	elif distance < 1000.0:
		self.apply_central_force(-dir * approach_speed )
	
	self.apply_central_force(tan_dir * orbit_speed)
	
	var over_the_line = global_position.y - (Global.water_y - water_buffer)
	if over_the_line > 0:
		apply_central_force(Vector2.UP * water_avoid_speed * over_the_line)

func _on_death() -> void:
	super()
	pass
