extends Enemy
class_name EyeballEnemy

## Time in seconds between ghost lazer and actual shot
@export var lazer_delay: float = 1.

## Spawns a ghost lazer for where it would be shooting, have it follow the player around, and then shoot
## after a short delay.
func lazer(p_ref: Player) -> void:
	# spawn ghost lazer
	# have ghost lazer follow player around
	await get_tree().create_timer(lazer_delay).timeout
	# fire lazer
	# Have an area2d check for collisions when the lazer fires, and apply atk to any player colliders
	var _atk = Attack.new()
	_atk.damage = 1.0
	pass

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
		marked.play_backwards("default")
