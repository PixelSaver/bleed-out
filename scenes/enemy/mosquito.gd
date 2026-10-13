extends Enemy
class_name MosquitoEnemy

## Delay between charging animation and actual charge
@export var charge_delay: float = 1.

func _on_death() -> void:
	pass

func highlight(do_highlight:bool) -> void:
	super(do_highlight)
	pass

# Probably add an area2d to check if player is in range, then follow player, and if in charge_range, then
# call charge at player using Global.player_ref

## Try to stab player after a delay
func charge(p_ref: Player) -> void:
	# play the windup animation
	await get_tree().create_timer(charge_delay).timeout # could also just await animation.finished
	# charge at player
	var alpha = 10.
	var _target = p_ref.global_position + p_ref.velocity * alpha
	pass
