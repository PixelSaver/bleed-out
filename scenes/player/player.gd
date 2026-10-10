extends CharacterBody2D

@export var grapple_ray: RayCast2D
@export var grapple_visual: Line2D

@export var walk_speed = 5000.0
@export var friction = 8.0
@export var jump_power = -1000.0
@export var gravity = 1000.0
@export var drift_speed = 500.0
@export var max_drift = 300.0
@export var momentum_cheat = 0.0 # 0.5
@export var damp_transfer = 1.0 # 0.5
@export var min_swing_speed = 700.0
@export var max_angular_vel = 20.0
#@export var min_angular_vel = 3.0
@export var min_rope_len = 100.0
@export var min_grapple_dist = 100.0
@export var spring_strength = 100.0
@export var spring_damping = 3.0
@export var pull_power = 250.0

@export var line_width = 10.0
@export var max_line_squish = 2.0


var grappling = false
var grapple_target: Node2D
var rope_len
var grapple_dist
var grapple_angle
var angular_vel
var radial_vel

var rope_taut = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	# Handle grapple/ungrapple
	if grappling:
		# Checking if rope is taut
		var grapple_offset = grapple_target.global_position - global_position
		if (grapple_offset.length() > rope_len || (grapple_offset.dot(velocity) < 0 && grapple_offset.length() >= min_rope_len)):
			slack_to_taut(grapple_offset.length() > rope_len)
		# Ungrappling if you let go of the button or hit some terrain
		if Input.is_action_just_released("grapple") or get_slide_collision_count() > 0:
			if rope_taut:
				# Proper velocity when releasing grapple
				velocity = (radial_vel * Vector2(cos(grapple_angle), sin(grapple_angle)) + grapple_dist * angular_vel * Vector2(-sin(grapple_angle), cos(grapple_angle)))
				rope_taut = false
				
			grappling = false
			grapple_visual.visible = false
		elif Input.is_action_just_pressed("attack"):
			velocity = (grapple_target.global_position - global_position).normalized() * pull_power * log(1.0 + grapple_dist)
			
			grappling = false
			grapple_visual.visible = false
			rope_taut = false
	else:
		if Input.is_action_just_pressed("grapple"):
			#grapple_ray.look_at(get_global_mouse_position())
			#grapple_ray.force_raycast_update()
			#if grapple_ray.is_colliding():
			grapple_target = Global.grapple_man.get_closest_grapple(self.global_position)
			var grapple_offset = global_position - grapple_target.global_position
			rope_len = max(grapple_offset.length(), min_rope_len)
			
			grappling = true
			grapple_visual.visible = true
	
	
	
	if rope_taut:
		# Radial velocity for the frame
		var spring_radial = -spring_strength * (grapple_dist - rope_len)
		var gravity_radial = gravity * sin(grapple_angle)
		#var centrifugal_radial = grapple_dist * angular_vel ** 2
		radial_vel += (spring_radial + gravity_radial) * delta
		# Spring damping
		# Some lost energy is instead converted to angular momentum
		var pre_damp = radial_vel
		radial_vel *= exp(-spring_damping * delta)
		var damped_energy = pre_damp ** 2 - radial_vel ** 2
		
		# Update grapple distance
		# but make sure you don't get even closer if you're already within the min dist
		var old_dist = grapple_dist
		grapple_dist += radial_vel * delta
		if grapple_dist < old_dist:
			grapple_dist = max(grapple_dist, min(min_grapple_dist, old_dist))
		
		# That effect where figure skaters spin faster without their arms out
		angular_vel += gravity * cos(grapple_angle) / grapple_dist * delta
		angular_vel *= (old_dist / grapple_dist) ** 2
		
		# Transfer damped radial energy into angular momentum
		# v = rw
		var tangent_vel = grapple_dist * angular_vel
		var new_tangent_vel = sqrt(tangent_vel ** 2 + damped_energy * damp_transfer)
		# var new_tangent_vel = sqrt(tangent_vel ** 2 + damped_energy * damp_transfer * maxf(0.0, sign(pre_damp)))
		# w = v/r
		angular_vel = sign(angular_vel) * new_tangent_vel / grapple_dist
		
		# Apply angular velocity
		# There is a minimum angular velocity
		#angular_vel = sign(angular_vel) * max(abs(angular_vel), min_swing_speed / grapple_dist)
		angular_vel = sign(angular_vel) * clamp(abs(angular_vel), min_swing_speed / grapple_dist, max_angular_vel)
		#angular_vel = sign(angular_vel) * maxf(abs(angular_vel), min_angular_vel)
		grapple_angle += angular_vel * delta
		var swing_to = grapple_target.global_position + grapple_dist * Vector2(cos(grapple_angle), sin(grapple_angle))
		velocity = (swing_to - global_position) / delta
	else:
		# Apply gravity
		if not is_on_floor():
			velocity.y += gravity * delta
		
		# Jump
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_power
			
		if is_on_floor():
			# Walking/friction
			velocity.x += Input.get_axis("left", "right") * walk_speed * delta
			velocity.x *= exp(-friction * delta)
		else:
			# Drifting in the air, very limited control
			var acceleration = Input.get_axis("left", "right") * drift_speed * delta
			if abs(velocity.x) < max_drift or sign(acceleration) != sign(velocity.x):
				velocity.x += acceleration
				var limit = max(max_drift, abs(velocity.x - acceleration))
				velocity.x = clampf(velocity.x, -limit, limit)

	move_and_slide()
	
	# Draw rope
	if grappling:
		grapple_visual.width = line_width * min((rope_len / (global_position - grapple_target.global_position).length()), max_line_squish)
		grapple_visual.points = [Vector2.ZERO, grapple_visual.to_local(grapple_target.global_position)]


func slack_to_taut(use_old_len: bool):
	var grapple_offset = global_position - grapple_target.global_position
	grapple_dist = grapple_offset.length()
	if not use_old_len:
		rope_len = grapple_dist
	grapple_angle = grapple_offset.angle()
	var radial_dir = grapple_offset.normalized()
	radial_vel = velocity.dot(radial_dir)
	var inward_vel = max(0.0, -velocity.dot(radial_dir))
	angular_vel = grapple_offset.cross(velocity) / grapple_offset.length_squared()
	# Convert a little momentum in the direction of the GrapplePoint to angular momentum
	# Technically not physically accurate, but feels funner
	angular_vel += sign(angular_vel) * inward_vel / grapple_dist * momentum_cheat
	
	rope_taut = true
