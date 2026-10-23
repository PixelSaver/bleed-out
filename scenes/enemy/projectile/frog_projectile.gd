extends Projectile
class_name FrogProjectile

@export var sprite: AnimatedSprite2D
var attack: Attack 
var initialized = false
var movement_vec: Vector2 = Vector2.ZERO
var lifetime: float = INF

@export var grow_duration: float = 1
@export var shrink_duration: float = 0.3
@export var homing_strength: float = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	scale = Vector2.ZERO
	create_tween().tween_property(self, "scale", Vector2.ONE, grow_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _on_body_entered(body:Node2D) -> void:
	if body is not Player:
		return
	var p = body as Player
	p.damage(attack)
	end_projectile()

## Maybe add an animation
func end_projectile() -> void:
	queue_free()

func initialize_movement(dir:Vector2, speed: float, _lifetime: float, atk: Attack) -> void:
	attack = atk
	movement_vec = dir * speed
	lifetime = _lifetime
	initialized = true
	self.rotation = randf() * 2 * PI

func _process(delta: float) -> void:
	if not initialized: return
	lifetime -= delta
	if lifetime <= 0:
		set_process(false)
		set_physics_process(false)
		monitoring = false
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2.ZERO, shrink_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		tween.tween_callback(end_projectile)

func _physics_process(delta: float) -> void:
	if not initialized: return

	var speed = movement_vec.length()
	var target_dir = (Global.player_ref.global_position - global_position).normalized()
	var current_dir = movement_vec.normalized()

	var new_dir = current_dir.move_toward(target_dir, homing_strength * delta)
	movement_vec = new_dir.normalized() * speed

	global_position += movement_vec * delta
