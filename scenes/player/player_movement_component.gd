extends Node
class_name PlayerMovementComponent

@export var slash: AnimatedSprite2D
@export var grapple_visual: Line2D
@export var player_sprite: AnimatedSprite2D
@export var sword_visual: Node2D
@export_group("Player Movement Tweaks")
## Power at which player bounces
@export var jump_power = -1000.0
## Constant downwards acceleration (units per second^2)
@export var gravity = 1000.0
### Air drift acceleration (units per second^2)
#@export var drift_speed = 500.0
#### Speed cap when only air drifting (units per second)
#@export var max_drift = 300.0
@export var bounce_damp = 0.8

## Increase gravity while swinging downwards
@export var gravity_boost = 2
@export var min_swing_speed = 700.0
@export var max_angular_vel = 20.0
@export var release_boost_normal = 100.0
@export var release_boost_tangent = 200.0

@export var min_rope_len = 100.0
@export var min_grapple_dist = 100.0
@export var spring_strength = 80.0
@export var spring_damping = 5.0
@export var pull_power = 250.0
@export var pull_duration = 0.25
@export var pull_invuln = 0.4
@export var parry_duration = 0.1
@export var parry_cooldown = 0.4
@export var parry_invuln = 0.15
@export var parry_strength = 300
@export var parry_min = -800
@export var throw_duration = 0.1
@export var retrieve_duration = 0.1
## Minimum time before you are allowed to release a grapple
@export var grapple_duration = 0.1

@export var line_width = 10.0
@export var max_line_squish = 2.0
## Distance between the sword's pivot and handle
@export var sword_len = 0.0

#@export var pull_required = 30.0
@export var pull_cost = 20.0
#@export var parry_required = 25.0
@export var parry_cost = 15.0

@export var angle_adjust_speed = 10.0

var prebounce_vel = Vector2.ZERO
var grapple_target: GrapplePoint
var rope_len = 0.0
var grapple_dist = 0.0
var grapple_angle = 0.0
var angular_vel = 0.0
var radial_vel = 0.0
var state_time
var parry_time = 9999.9
var pull_vel
var pull_start_point
var rope_taut = false
var rope_from: Vector2
var rope_to: Vector2

enum State {
	NORMAL,
	GRAPPLE,
	PULL,
	PARRY,
	THROW,
	RETRIEVE
}

var state = State.NORMAL

func _initiate_grapple(target: GrapplePoint, p: Player) -> void:
	var prev_e: Enemy
	if grapple_target != null:
		prev_e = grapple_target.get_enemy()
		if prev_e != null:
			pass
	grapple_target = target
	var grapple_offset = p.global_position - grapple_target.global_position
	rope_len = max(grapple_offset.length(), min_rope_len)

	rope_from = p.global_position
	rope_to = grapple_target.global_position
	state = State.THROW
	state_time = 0.0
	player_sprite.play("swing")
	var sound = [AudioManager.Sound.GRAPPLE_1, AudioManager.Sound.GRAPPLE_2].pick_random()
	AudioManager.play_sfx(sound, -10)
	update_grapple_visibility(true)

func _ungrapple(p:Player, jump:bool) -> void:
	if rope_taut:
		# Proper velocity when releasing grapple
		if jump:
			p.velocity = ((radial_vel + release_boost_normal) * Vector2(cos(grapple_angle), sin(grapple_angle))
						+ (grapple_dist * angular_vel + sign(angular_vel) * release_boost_tangent) * Vector2(-sin(grapple_angle), cos(grapple_angle)))
		else:
			p.velocity = ((radial_vel) * Vector2(cos(grapple_angle), sin(grapple_angle))
						+ (grapple_dist * angular_vel) * Vector2(-sin(grapple_angle), cos(grapple_angle)))

		rope_taut = false

	if grapple_target == null:
		state = State.NORMAL
		update_grapple_visibility(false)
	else:
		rope_from = p.global_position
		rope_to = grapple_target.global_position
		state = State.RETRIEVE
		state_time = 0.0
		if grapple_target.get_enemy() != null:
			grapple_target.get_enemy().freeze_enemy(false)
		player_sprite.play("unswing")

func _pull(p:Player, delta: float) -> void:
	if p == null: return
	#var direction = grapple_target.global_position - p.global_position
	#var n_dir = direction.normalized()
	#var angle = direction.angle()

	#player_sprite.flip_h = if n_dir > 
	#player_sprite.flip_v = direction.x < 0
	#player_sprite.rotation = angle
	
	state_time += delta
	var t_norm = min(state_time / pull_duration, 1.0)
	# Formula for cubic Hermite interpolation with starting vel of (0,0)
	# Just google it
	p.global_position = pull_start_point + (3 * t_norm ** 2 - 2 * t_norm ** 3) * (grapple_target.global_position - pull_start_point) + (t_norm ** 3 - t_norm ** 2) * pull_duration * pull_vel
	if state_time >= pull_duration:
		p.velocity = pull_vel
		state = State.NORMAL
		update_grapple_visibility(false)
		rope_taut = false
		if grapple_target != null and grapple_target.get_enemy() != null:
			var e: Enemy = grapple_target.get_enemy()
			e.freeze_enemy(false)
			e.apply_central_impulse(pull_vel * -10.)

func _initiate_pull(p: Player) -> void:
	if player_sprite.animation != "dash":
		player_sprite.play("dash", 1/pull_duration)
	var sound = [AudioManager.Sound.DASH].pick_random()
	AudioManager.play_sfx(sound, -10)
	var offset = grapple_target.global_position - p.global_position
	pull_vel = offset.normalized() * pull_power * log(1.0 + offset.length())
	state = State.PULL
	state_time = 0.0
	p.set_invincibility(pull_invuln)
	if player_sprite.flip_h:
		player_sprite.rotate(PI/2)
	else:
		player_sprite.rotate(-PI/2)

func process_movement(p:Player, delta: float) -> void:
	var temp_grapple_target = p.search_grapple_points(Global.enemy_man.get_enemy_grapple_points())
	match state:
		State.NORMAL:
			if parry_time < parry_cooldown:
				parry_time += delta
			
			if Input.is_action_just_pressed("grapple"):
				if temp_grapple_target:
					_initiate_grapple(temp_grapple_target, p)
			elif Input.is_action_just_pressed("attack") and parry_time >= parry_cooldown:
				p.spend_blood(parry_cost)
				state = State.PARRY
				state_time = 0.0
				p.set_invincibility(parry_invuln)
				slash.play("slash")

			normal_physics(p, delta)
			smooth_upright(delta)

		State.GRAPPLE:
			# Checking if rope is taut
			if grapple_target == null:
				_ungrapple(p, true)
			else:
				var grapple_offset = grapple_target.global_position - p.global_position
				if not rope_taut and (grapple_offset.length() > rope_len or (grapple_offset.dot(p.velocity) < 0 and grapple_offset.length() >= min_rope_len)):
					slack_to_taut(p, grapple_offset.length() > rope_len)
				state_time += delta
				# Ungrappling if you let go of the button
				if not Input.is_action_pressed("grapple") and state_time >= grapple_duration:
					_ungrapple(p, true)
				elif Input.is_action_just_pressed("attack"):
					p.spend_blood(pull_cost)
					_initiate_pull(p)

			normal_physics(p, delta)
			draw_rope(p, true, 1.0)
			if state != State.PULL:
				if rope_taut:
					player_sprite.rotation = grapple_angle - PI / 2
				else:
					smooth_upright(delta)

		State.PULL:
			_pull(p, delta)
			draw_rope(p, false, 1.0)
			#smooth_upright(delta)

		State.PARRY:
			
			var hit_enemies = p.parry_hitbox.get_overlapping_bodies()
			if hit_enemies:
				AudioManager.play_sfx(AudioManager.Sound.PARRY_SUCCESS, -15)
				for enemy in hit_enemies:
					if enemy == null:
						return
					var atk = Attack.new()
					atk.damage = 1
					atk.direction = (enemy.global_position - p.global_position).normalized()
					atk.player_hit = true
					enemy.damage(atk)
				p.velocity.y = min(parry_min, p.velocity.y - parry_strength)
				state = State.NORMAL
				p.drink()
			state_time += delta
			if state_time > parry_duration:
				state = State.NORMAL
				if not hit_enemies:
					AudioManager.play_sfx(AudioManager.Sound.PARRY, -5)
				parry_time = 0.0

			normal_physics(p, delta)
			smooth_upright(delta)

		State.THROW:
			state_time += delta
			var t_norm = min(state_time / throw_duration, 1.0)
			if state_time > throw_duration:
				state_time = 0.0
				state = State.GRAPPLE
				if grapple_target != null:
					# Attacking enemy
					var e = grapple_target.get_enemy()
					if e != null:
						var atk = Attack.new()
						atk.damage = 1
						atk.direction = (e.global_position - p.global_position).normalized()
						atk.player_hit = true
						e.freeze_enemy(true, atk)

						p.drink()
			normal_physics(p, delta)
			if grapple_target: 
				rope_to = grapple_target.global_position
				draw_rope(p, false, t_norm)
				smooth_upright(delta)

		State.RETRIEVE:
			state_time += delta
			var t_norm = 1 - min(state_time / retrieve_duration, 1.0)
			if state_time > retrieve_duration:
				state = State.NORMAL
				update_grapple_visibility(false)
			normal_physics(p, delta)
			rope_from = p.global_position
			draw_rope(p, false, t_norm)
			smooth_upright(delta)
			
	if angular_vel > 0:
		player_sprite.flip_h = true
	elif angular_vel < 0:
		player_sprite.flip_h = false

func smooth_upright(delta):
	player_sprite.rotation = lerp_angle(player_sprite.rotation, 0.0, 1.0 - exp(-angle_adjust_speed * delta))

func normal_physics(p: Player, delta: float):
	if rope_taut:
		# Radial velocity for the frame
		var spring_radial = -spring_strength * (grapple_dist - rope_len)
		var gravity_radial
		gravity_radial = gravity * sin(grapple_angle)
		var centrifugal_radial = grapple_dist * angular_vel ** 2
		radial_vel += (spring_radial + gravity_radial + centrifugal_radial) * delta
		# Spring damping
		radial_vel *= exp(-spring_damping * delta)

		# Update grapple distance
		# but make sure you don't get even closer if you're already within the min dist
		var old_dist = grapple_dist
		grapple_dist += radial_vel * delta
		if grapple_dist < old_dist:
			grapple_dist = max(grapple_dist, min(min_grapple_dist, old_dist))

		# Apply gravity to spin
		if angular_vel * cos(grapple_angle) > 0:
			# Extra gravity when going down
			angular_vel += gravity * gravity_boost * cos(grapple_angle) / grapple_dist * delta
		else:
			angular_vel += gravity / gravity_boost * cos(grapple_angle) / grapple_dist * delta

		# That effect where figure skaters spin faster without their arms out
		angular_vel *= (old_dist / grapple_dist) ** 2

		# Apply angular velocity
		# There is a minimum angular velocity
		angular_vel = sign(angular_vel) * clamp(abs(angular_vel), min_swing_speed / grapple_dist, max_angular_vel)
		# Bounce off when you hit a wall
		if p.is_on_wall() and sign(sin(grapple_angle)) * sign(angular_vel) * sign(p.get_wall_normal().x) > 0:
			angular_vel *= -1
		grapple_angle += angular_vel * delta
		var swing_to = grapple_target.global_position + grapple_dist * Vector2(cos(grapple_angle), sin(grapple_angle))
		p.velocity = (swing_to - p.global_position) / delta
	else:
		# Apply gravity
		if not p.is_on_floor():
			p.velocity.y += gravity * delta

		## Drifting in the air, very limited control
		#var acceleration = Input.get_axis("left", "right") * drift_speed * delta
		#if abs(p.velocity.x) < max_drift or sign(acceleration) != sign(p.velocity.x):
			#p.velocity.x += acceleration
			#var limit = max(max_drift, abs(p.velocity.x - acceleration))
			#p.velocity.x = clampf(p.velocity.x, -limit, limit)

		if p.is_on_floor():
			if state == State.PARRY:
				p.velocity.y = prebounce_vel.y * -1
			else:
				p.velocity.y = jump_power

		if p.is_on_wall():
			if state == State.PARRY:
				p.velocity.x = prebounce_vel.x * -1
			else:
				p.velocity.x = prebounce_vel.x * -1 * bounce_damp

	prebounce_vel = p.velocity
	p.move_and_slide()
	pull_start_point = p.global_position

func draw_rope(p: Player, change_width: bool, t: float):
	var sword_position = lerp(grapple_visual.to_local(rope_from), grapple_visual.to_local(rope_to), t)
	sword_visual.position = sword_position
	sword_visual.rotation = sword_position.angle()
	var handle_position = sword_position - sword_position.normalized() * sword_len
	if change_width:
		grapple_visual.width = line_width * min(((rope_len - sword_len) / (handle_position).length()), max_line_squish)
	grapple_visual.points = [Vector2.ZERO, handle_position]

func slack_to_taut(p: Player, use_old_len: bool):
	var grapple_offset = p.global_position - grapple_target.global_position
	grapple_dist = grapple_offset.length()
	if not use_old_len:
		rope_len = grapple_dist
	grapple_angle = grapple_offset.angle()
	var radial_dir = grapple_offset.normalized()
	radial_vel = p.velocity.dot(radial_dir)
	angular_vel = grapple_offset.cross(p.velocity) / grapple_offset.length_squared()

	rope_taut = true

func update_grapple_visibility(visibility: bool):
	grapple_visual.visible = visibility
	sword_visual.visible = visibility

func let_go(p: Player):
	if state == State.GRAPPLE:
		_ungrapple(p, false)
