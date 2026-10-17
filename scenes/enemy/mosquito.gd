extends Enemy
class_name MosquitoEnemy

## Area2d that determines what distance it will try to charge at player
@export var charge_range: Area2D
## The range at which the mosquito will start following the player 
@export var vision_range: Area2D
## Delay between charging animation and actual charge
@export var charge_delay: float = 0.5
## Impulse strength for charging
@export var charge_strength: float = 10.
## Delay between the last charge and trying to charge again
@export var charge_cooldown: float = 2.
var _charge_cooldown_timer: float = -INF
var can_see_player: bool = false
signal charge_cooldown_ended

func _ready() -> void:
	super()
	charge_range.body_entered.connect(_on_charge_body_entered)
	charge_cooldown_ended.connect(func():
		try_charge_again()
	)
	vision_range.body_entered.connect(_on_vision_body_entered)
	vision_range.body_exited.connect(_on_vision_body_exited)
	
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
	

func _on_charge_body_entered(body: Node2D) -> void:
	if body is not Player: return
	var p = body as Player
	charge(p)

func _physics_process(delta: float) -> void:
	if not can_see_player or _charge_cooldown_timer > 0: return
	var alpha = 0.2
	var dir = Global.player_ref.global_position + Global.player_ref.velocity * alpha - self.global_position
	dir = dir.normalized()
	self.apply_central_force(dir * speed * 80000 * delta)

func _process(delta: float) -> void:
	if _charge_cooldown_timer >= 0:
		_charge_cooldown_timer -= delta
		if _charge_cooldown_timer <= 0:
			charge_cooldown_ended.emit()
	

## Called at the end of charge to attack player again if they haven't left the range
func try_charge_again() -> void:
	if charge_range.has_overlapping_bodies():
		for body in charge_range.get_overlapping_bodies():
			if body is Player:
				charge(body as Player)

func _on_death() -> void:
	pass

func highlight(do_highlight:bool) -> void:
	super(do_highlight)
	pass

# Probably add an area2d to check if player is in range, then follow player, and if in charge_range, then
# call charge at player using Global.player_ref

## Try to stab player after a delay
func charge(p_ref: Player) -> void:
	if _charge_cooldown_timer > 0: 
		return
	_charge_cooldown_timer = charge_cooldown
	# play the windup animation
	await get_tree().create_timer(charge_delay).timeout # could also just await animation.finished
	# charge at player
	var alpha = .0
	var target = p_ref.global_position + p_ref.velocity * alpha
	var dir = target - global_position
	self.apply_central_impulse(dir.normalized() * charge_strength)
	# await charge cooldown before moving again
	await get_tree().create_timer(charge_cooldown).timeout
	try_charge_again()
	pass
