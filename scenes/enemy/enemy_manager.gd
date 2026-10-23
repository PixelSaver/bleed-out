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
@export var spawn_chunk_population: int = 2
@export var starting_y: float = -1200.0

@export var goblin_dropoff: float = 6000.
## How quickly goblins become rare.
@export var goblin_decay: float = 80000.0

## Height at which mosquitoes first appear.
@export var mosquito_start_height: float = 4000.
## How quickly mosquitos become common.
@export var mosquito_growth: float = 19000.0

## Frog introduction and growth.
@export var frog_start_height: float = 10000.0
@export var frog_growth: float = 25000.0
@export var frog_max_weight: float = 0.4

## First eyeball appears around this height.
@export var eyeball_start_height: float = 26000.0

@export var eyeball_max_spacing: float = 11000.0
@export var eyeball_final_max_spacing: float = 4500.0
@export var eyeball_spacing_decay: float = 70000.0

@export var eyeball_initial_noise: float = 1000.0
@export var eyeball_max_noise: float = 4000.0
@export var eyeball_noise_growth: float = 60000.0
@export var eyeball_noise_power: float = 1.6

## Overall eyeball spawn frequency multiplier.
@export var eyeball_frequency: float = 1.0
var last_spawn_chunk: int = 0
var should_spawn := false

var next_eyeball_height: float = -1.0

func get_eyeball_spacing(h: float) -> float:
	var progress := maxf(0.0, h - eyeball_start_height)
	var max_spacing := eyeball_final_max_spacing + (eyeball_max_spacing - eyeball_final_max_spacing) * exp(-progress / eyeball_spacing_decay)
	var noise := eyeball_initial_noise + (eyeball_max_noise - eyeball_initial_noise) * pow(1.0 - exp(-progress / eyeball_noise_growth),eyeball_noise_power)
	return randf_range(max_spacing - noise, max_spacing) / eyeball_frequency

## Determines if enemies spawn.
func set_should_spawn(_spawn:bool) -> void:
	should_spawn = _spawn

func get_spawn_weights(h: float) -> Dictionary[EnemyType, float]:
	var goblin := 0.1 + 0.9 * exp(
		-maxf(0.0, h - goblin_dropoff) / goblin_decay
	)
	var mosquito_height := maxf(0.0, h - mosquito_start_height)
	var mosquito := 1.0 - exp(-mosquito_height / mosquito_growth)
	var frog_height := maxf(0.0, h - frog_start_height)
	var frog := frog_max_weight * (
		1.0 - exp(-frog_height / frog_growth)
	)
	return {
		EnemyType.GOBLIN: goblin,
		EnemyType.MOSQUITO: mosquito,
		EnemyType.FROG: frog,
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
		var n = spawn_chunk_population
		for i in range(n):
			var type = EnemyType.EYEBALL if i == 0 and height >= next_eyeball_height else pick_enemy_type(height)
			if type == EnemyType.EYEBALL:
				next_eyeball_height = height + get_eyeball_spacing(height)
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
	# Seed rng
	randomize()
	next_eyeball_height = eyeball_start_height + randf_range(-1000.0, 1000.0)

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
		if not e:
			continue
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
