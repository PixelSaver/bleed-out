extends Enemy
class_name FrogEnemy

@export var shot_range: Area2D
@export var shot_cooldown: float = 1.0
@export var projectile_speed: float = 10.
@export var projectile_lifetime: float = 10.
## Counts down per frame to check if frog can shoot
var _shot_cooldown = -INF
signal shot_cooldown_ended

func _ready() -> void:
	super()
	shot_range.body_entered.connect(_on_body_entered)
	shot_cooldown_ended.connect(func():
		try_shoot_again()
	)

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
	pass

func highlight(do_highlight:bool) -> void:
	super(do_highlight)
	pass

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
	atk.damage = 1.0
	frog_proj.initialize_movement(dir, projectile_speed, projectile_lifetime, atk)
	
	pass
