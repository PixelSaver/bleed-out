## Class which holds all enemy scenes in the current scene, which also helps sort through them
extends Node2D
class_name EnemyManager

var enemies: Array[Enemy] = []
var highlighted_enemy: Enemy = null

func _ready() -> void:
	Global.enemy_man = self
	for child in get_children():
		if child is Enemy and not enemies.has(child):
			enemies.append(child)
	SignalBus.highlight_enemy.connect(_on_enemy_highlight)

func _on_enemy_highlight(e:Enemy) -> void:
	if e == highlighted_enemy or e == null: return
	if highlighted_enemy != null:
		highlighted_enemy.highlight(false)
	e.highlight(true)
	highlighted_enemy = e

func get_enemies() -> Array[Enemy]:
	return enemies
## Returns all grapple points under enemies
func get_enemy_grapple_points() -> Array[GrapplePoint]:
	var out: Array[GrapplePoint] = []
	for e in enemies:
		out.append(e.grapple_point)
	return out

## Returns closest enemy to the global player position, returns null if fails
func get_closest_grapple(global_player_position:Vector2) -> Enemy:
	var out: Enemy = null
	for grapple in enemies:
		if out == null:
			out = grapple
		elif grapple.global_position.distance_to(global_player_position) < \
			out.global_position.distance_to(global_player_position):
				out = grapple
	return out if out != null else null
