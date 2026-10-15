## Class which holds all enemy scenes in the current scene, which also helps sort through them
extends Node2D
class_name EnemyManager

var enemies: Array[Enemy] = []
var highlighted_enemy: Enemy = null

#region Scene loading
enum EnemyType {
	GOBLIN,
	MOSQUITO,
	FROG,
	EYEBALL,
}
const DEFAULT_ENEMY_SCENE = EnemyType.GOBLIN
var enemy_scenes: Dictionary[EnemyType, PackedScene] = {
	EnemyType.GOBLIN: preload("res://scenes/enemy/goblin.tscn"),
	EnemyType.MOSQUITO: preload("res://scenes/enemy/mosquito.tscn"),
	EnemyType.FROG: preload("res://scenes/enemy/frog.tscn"),
	EnemyType.EYEBALL: preload("res://scenes/enemy/eyeball.tscn"),
}
## To spawn an enemy, get the scene, instantiate it, and use EnemyManager.register_enemy(scene)
func get_enemy_scene(type: EnemyType) -> PackedScene:
	if enemy_scenes.has(type):
		return enemy_scenes.get(type)
	else: 
		print("Failed to get enemy scene #(%s), returning scene#(%s)" % [type, DEFAULT_ENEMY_SCENE])
		return enemy_scenes.get(DEFAULT_ENEMY_SCENE)
#endregion

#region Enemy Spawning
## Use the player y level to modulate difficulty and stuff
func pick_enemy_type(_y:float) -> EnemyType:
	return EnemyType.values().pick_random()

## Adds the enemy to the scene and registers it with the enemy manager
func register_enemy(e:Enemy) -> void:
	if enemies.has(e): 
		return
	if e.get_parent() != self:
		add_child(e)
	enemies.append(e)

func _input(event: InputEvent) -> void:
	if not OS.is_debug_build(): return
	if event.is_action_pressed("debug"):
		var type = pick_enemy_type(0)
		var scene = get_enemy_scene(type)
		var e = scene.instantiate() as Enemy
		register_enemy(e)
		e.global_position = Global.player_ref.global_position

#endregion

func _ready() -> void:
	Global.enemy_man = self
	for child in get_children():
		if child is Enemy:
			register_enemy(child)
	SignalBus.highlight_enemy.connect(_on_enemy_highlight)

func _on_enemy_highlight(e:Enemy) -> void:
	if e == null:
		if highlighted_enemy:
			highlighted_enemy.highlight(false)
			highlighted_enemy = null
		return
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
