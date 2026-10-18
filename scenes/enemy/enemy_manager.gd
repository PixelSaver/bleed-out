## Class which holds all enemy scenes in the current scene, which also helps sort through them
extends Node2D
class_name EnemyManager

var enemies: Array[Enemy] = []
var highlighted_enemy: Enemy = null

#region Enemy Spawning
@export var debug_spawn_toggle: bool = false
@export_group("Spawn Distribution")
## Height above player which enemies will spawn 
@export var spawn_buffer: float = 1500.
## Spawn enemies called per chunk
@export var spawn_chunk_size: float = 500.
@export var starting_y: float = 000.

@export var goblin_dropoff: float = 3000.
## How quickly goblins become rare.
@export var goblin_decay: float = 2000.0

@export var mosquito_dropoff: float = 3700.
## How quickly mosquitos become common.
@export var mosquito_growth: float = 3000.0

## Frog introduction and growth.
@export var frog_start_height: float = 7000.0
@export var frog_growth: float = 8000.0
@export var frog_max_weight: float = 0.4

## Eyeball introduction and growth.
@export var eyeball_start_height: float = 10000.0
@export var eyeball_growth: float = 8000.0
@export var eyeball_max_weight: float = 0.12
var last_spawn_chunk: int = 0


func get_spawn_weights(h: float) -> Dictionary[EnemyType, float]:
	var goblin := 0.1 + 0.9 * exp(-(h-goblin_dropoff) / goblin_decay)
	var mosquito := minf(
		0.2 + 0.8 * (
			1.0 - exp(-(h-mosquito_dropoff) / mosquito_growth)
		),
		1.0
	)
	var frog_height := maxf(0.0, h - frog_start_height)
	var frog := maxf(
		frog_max_weight * (
			1.0 - exp(-frog_height / frog_growth)
		),
		0.0
	)
	var eyeball_height := maxf(0.0, h - eyeball_start_height)
	var eyeball := eyeball_max_weight * (
		1.0 - exp(-eyeball_height / eyeball_growth)
	)
	return {
		EnemyType.GOBLIN: goblin,
		EnemyType.MOSQUITO: mosquito,
		EnemyType.FROG: frog,
		EnemyType.EYEBALL: eyeball,
	}
func normalize_weights(d: Dictionary[EnemyType, float]) -> Dictionary[EnemyType, float]:
	var t = 0.;
	for type in EnemyType.values():
		t += d.get(type)
	for type in EnemyType.values():
		d.set(type, d.get(type) / t)
	return d
func pick_random_weight(
	d: Dictionary[EnemyType, float]
) -> EnemyType:
	var total := 0.0
	for weight in d.values():
		total += weight
	if total <= 0.0:
		return DEFAULT_ENEMY_SCENE
	var r := randf() * total
	for type in EnemyType.values():
		r -= d.get(type, 0.0)
		if r < 0.0:
			return type
	return DEFAULT_ENEMY_SCENE
	
## Use the player y level to modulate difficulty and stuff
func pick_enemy_type(y:float) -> EnemyType:
	var weights := get_spawn_weights(y)
	return pick_random_weight(weights)

## Adds the enemy to the scene and registers it with the enemy manager
func register_enemy(e:Enemy) -> void:
	if enemies.has(e): 
		return
	if e.get_parent() != self:
		add_child(e)
	enemies.append(e)

func unregister_enemy(e:Enemy) -> void:
	if enemies.has(e):
		enemies.erase(e)

func _input(event: InputEvent) -> void:
	if not OS.is_debug_build(): return
	if event.is_action_pressed("debug"):
		var type = pick_enemy_type(0)
		var scene = get_enemy_scene(type)
		var e = scene.instantiate() as Enemy
		register_enemy(e)
		e.global_position = Global.player_ref.global_position

func _process(_delta: float) -> void:
	if OS.is_debug_build() and debug_spawn_toggle == true: return
	var p = Global.player_ref
	if p == null: return
	var current_chunk: int = floori(
		(starting_y - p.global_position.y + spawn_buffer)
		/ spawn_chunk_size
	)
	while current_chunk > last_spawn_chunk:
		# spawn enemy chunk
		var height := last_spawn_chunk * spawn_chunk_size
		var chunk_y := starting_y - height
		## number of enemies per chunk, might functionize later
		var n = 5
		for i in range(n):
			var type = pick_enemy_type(height)
			var scene = get_enemy_scene(type)
			var e = scene.instantiate() as Enemy
			register_enemy(e)
			e.global_position = Vector2(randf_range(-500, 500), chunk_y - clampf(randfn(spawn_chunk_size * .5, spawn_chunk_size*.3), 0.0, spawn_chunk_size) )
		last_spawn_chunk += 1
		
#endregion

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

func _ready() -> void:
	Global.enemy_man = self
	for child in get_children():
		if child is Enemy:
			register_enemy(child)
	SignalBus.highlight_enemy.connect(_on_enemy_highlight)

func _on_enemy_highlight(e:Enemy) -> void:
	if e == highlighted_enemy: return
	if highlighted_enemy:
		highlighted_enemy.highlight(false)
		highlighted_enemy = null
	if e == null:
		return
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
