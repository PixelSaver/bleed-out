extends Node

enum States {
	START,
}
var state : States = States.START

var menu_manager: PixelMenuManager

var enemy_man: EnemyManager

var player_ref: Player
