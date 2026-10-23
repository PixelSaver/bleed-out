extends RigidBody2D
class_name Enemy

#@export var debug = ""

@export var touch_damage: float = 30.0
@export var touch_area: Area2D
@export var grapple_point: GrapplePoint
@export var health_component: HealthComponent
@export var blood_spray: GPUParticles2D
@export var blood_offset: float = 0.0
@export var marked: AnimatedSprite2D
@export var speed: float = 10.
signal frozen(is_frozen:bool)
var _queued_atk: Attack = null
var killed_by_player = false

func _ready() -> void:
	health_component.death.connect(_on_death)
	frozen.connect(_on_freeze)
	touch_area.body_entered.connect(_on_enemy_body_entered)

func _on_enemy_body_entered(body: Node2D) -> void:
	if freeze: return
	if body is not Player: return
	var p = body as Player
	if p == null: return
	var atk = Attack.new()
	atk.damage = touch_damage
	var dir = p.global_position - self.global_position
	dir = dir.normalized()
	atk.knockback = dir * 500
	p.damage(atk)

var is_highlighted = false
func highlight(do_highlight:bool) -> void:
	if do_highlight and not is_highlighted:
		is_highlighted = true
		#if marked == null:
			##print(debug)
		marked.set_frame(0)
		marked.play("default", 1.)
	elif do_highlight == false and is_highlighted == true:
		is_highlighted = false
		marked.set_frame(0)
		marked.play("default", -2., true)

func damage(atk:Attack) -> void:
	killed_by_player = atk.player_hit
	health_component.damage(atk)

## Function to toggle freezing of the enemy, stopping AI and special moves. 
## Queue an attack to be done when unfrozen
func freeze_enemy(do_freeze: bool=true, queued_atk: Attack=null) -> void:
	call_deferred("_freeze_self_deferred", do_freeze)
	frozen.emit(do_freeze)
	if do_freeze:
		_queued_atk = queued_atk
		blood_spray.global_rotation = queued_atk.direction.angle() + PI
		blood_spray.position = Vector2(blood_offset, 0).rotated(blood_spray.rotation)
		blood_spray.restart()
	elif _queued_atk != null:
		self.damage(_queued_atk)
	
func _freeze_self_deferred(do_freeze:bool) -> void:
	self.freeze = do_freeze

func _on_freeze(_frozen: bool) -> void:
	
	pass

func _on_death() -> void:
	# Blood explosion
	if killed_by_player:
		var explosion = preload("res://scenes/blood_particle/blood_explosion.tscn").instantiate() as GPUParticles2D
		AudioManager.play_sfx(AudioManager.Sound.BLOOD_EXPLODE)
		get_parent().add_child(explosion)
		explosion.global_position = global_position
		explosion.one_shot = true
		explosion.emitting = true
		explosion.finished.connect(explosion.queue_free)
	
	# Remove enemy
	Global.enemy_man.unregister_enemy(self)
	queue_free()
	pass

func get_grapple_point() -> GrapplePoint:
	return grapple_point if grapple_point else null

#func highlight(do_highlight:bool) -> void:
	#$HighlightPROTOTYPE.color.a = 0.4 if do_highlight else 0.0
