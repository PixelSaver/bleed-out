extends Control

class_name PixelMenuManager

@export var first_scene : PackedScene
@export var debug_first_scene : PackedScene

enum MenuManagerState {
	## There is a single menu existing
	SINGLE,
	## There is one menu going through it's end animation
	TRANSITIONING_AWAY,
	## There is one menu going through it's start animation
	TRANSITIONING_TOWARDS,
	## There are two menus, one ending, one starting
	TRANSITIONING_BOTH,
}
var state: MenuManagerState = MenuManagerState.SINGLE
var current_scene: PixelMenu
var previous_scene: PixelMenu

func transition_to_scene(new_scene:PackedScene):
	if previous_scene:
		previous_scene.queue_free()
	if current_scene:
		previous_scene = current_scene
		current_scene.end_anim()
	current_scene = new_scene.instantiate() as PixelMenu
	add_child(current_scene)
	current_scene.start_anim()

func _ready() -> void:
	Global.menu_manager = self
	if OS.is_debug_build() and debug_first_scene:
		transition_to_scene(debug_first_scene)
		return
	if first_scene:
		transition_to_scene(first_scene)
