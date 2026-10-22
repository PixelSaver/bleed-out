extends Node

enum States {
	START,
}
var state : States = States.START

var menu_manager: PixelMenuManager
var projectile_man: ProjectileManager
var enemy_man: EnemyManager

var player_ref: Player
var max_y: float = 0.
var water_y: float = 0.
