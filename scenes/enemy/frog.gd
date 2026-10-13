extends Enemy
class_name FrogEnemy



func _on_death() -> void:
	pass

func highlight(do_highlight:bool) -> void:
	super(do_highlight)
	pass

# Probably add an area2d to check if player is in range, then shoot if within shooting range
# if too far, then follow player until in shooting range

## Takes into account the current player's velocity (probably)
func shoot(p_pos: Vector2, p_velocity: Vector2) -> void:
	var alpha: float = 10
	var _target = p_pos + p_velocity * alpha
	# Instantiate projectile, move it to position and set it's velocity
	# give projectile attack
	var _atk = Attack.new()
	_atk.damage = 1.0
	pass
