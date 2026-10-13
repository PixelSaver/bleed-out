extends Node2D
class_name ProjectileManager

enum ProjectileType {
	FROG,
}

var projectiles: Array[Projectile] = []

var projectile_scenes: Dictionary[ProjectileType, PackedScene] = {
	ProjectileType.FROG: preload("res://scenes/enemy/projectile/frog_projectile.tscn"),
}
## Spawns and registers projectile of the given type. Returns the projectile to allow initialization later
func spawn_projectile(type:ProjectileType) -> Projectile:
	if not projectile_scenes.keys().has(type): return
	var proj = projectile_scenes.get(type).instantiate() as Projectile
	call_deferred("deferred_add_child", proj)
	return proj

func deferred_add_child(node:Node2D):
	add_child(node)

func _ready() -> void:
	Global.projectile_man = self
