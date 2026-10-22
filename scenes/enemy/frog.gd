extends Enemy
class_name FrogEnemy

@export var anim_sprite: AnimatedSprite2D
@export var shot_range: Area2D
@export var vision_range: Area2D
@export var proj_damage: float = 15.
## Distance at which the enemy stops following and starts shooting.
@export var shot_cooldown: float = 1.0
@export var projectile_speed: float = 10.
@export var projectile_lifetime: float = 10.
@export var follow_distance: float = 500.
## Counts down per frame to check if frog can shoot
var _shot_cooldown = -INF
var can_see_player: bool = false
signal shot_cooldown_ended

func _ready() -> void:
	super()
	shot_range.body_entered.connect(_on_body_entered)
	shot_cooldown_ended.connect(func():
		try_shoot_again()
	)
	vision_range.body_entered.connect(_on_vision_body_entered)
	vision_range.body_exited.connect(_on_vision_body_exited)
	_shot_cooldown = shot_cooldown * randf()
	await get_tree().create_timer(randf()).timeout
	anim_sprite.play("idle", randf_range(0.9, 1.1))
	
func _on_vision_body_entered(body: Node2D) -> void:
	if body is not Player: return
	var p = body as Player
	if p == null: return
	can_see_player = true
func _on_vision_body_exited(body: Node2D) -> void:
	if body is not Player: return
	var p = body as Player
	if p == null: return
	can_see_player = false

func _on_body_entered(body: Node2D) -> void:
	if body is not Player: return
	var p = body as Player
	shoot(p)
	
## Called at the end of charge to attack player again if they haven't left the range
func try_shoot_again() -> void:
	if shot_range.has_overlapping_bodies():
		for body in shot_range.get_overlapping_bodies():
			if body is Player:
				shoot(body as Player)

func _on_death() -> void:
	super()
	pass

func _physics_process(delta: float) -> void:
	if not can_see_player: return
	var p_to_e: Vector2 = self.global_position - Global.player_ref.global_position
	# If too close to player
	if p_to_e.length() < follow_distance + 50:
		# Target position local to player 
		var target_plocal = p_to_e.normalized() * follow_distance
		var target = Global.player_ref.global_position + target_plocal
		var dir = target - self.global_position
		dir = dir.normalized()
		self.apply_central_force(dir * speed * 10000 * delta)
		return
	else:
		var alpha = 0.2
		var dir = Global.player_ref.global_position + Global.player_ref.velocity * alpha - self.global_position
		dir = dir.normalized()
		self.apply_central_force(dir * speed * 80000 * delta)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if _shot_cooldown >= 0:
		_shot_cooldown -= delta
		if _shot_cooldown <= 0:
			shot_cooldown_ended.emit()

# Probably add an area2d to check if player is in range, then shoot if within shooting range
# if too far, then follow player until in shooting range

## Takes into account the current player's velocity
func shoot(p:Player) -> void:
	if _shot_cooldown > 0.: return
	anim_sprite.play("fire")
	var sound = [AudioManager.Sound.FROG_FIRE_1, AudioManager.Sound.FROG_FIRE_2].pick_random()
	AudioManager.play_sfx_2d(self, sound, -20)
	await anim_sprite.animation_finished
	_shot_cooldown = shot_cooldown
	var frog_proj = Global.projectile_man.spawn_projectile(ProjectileManager.ProjectileType.FROG) as FrogProjectile
	if frog_proj == null:
		push_error("Frog projectile returned wasn't frog projectile.")
		return
	frog_proj.global_position = self.global_position
	var alpha: float = 0.3
	var target = p.global_position + p.velocity * alpha
	var dir = target - global_position
	dir = dir.normalized()
	var atk = Attack.new()
	atk.damage = proj_damage
	frog_proj.initialize_movement(dir, projectile_speed, projectile_lifetime, atk)
	await get_tree().create_timer(0.3).timeout
	anim_sprite.play("idle")
	pass
