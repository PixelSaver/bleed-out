extends Node

const DEFAULT_SCENE = Scene.START
enum Scene {
	START,
	SETTINGS,
	GRAPPLE_TEST,
	LEVEL_TEST_2,
	GAME,
}

var scenes = {
	Scene.START: preload("res://scenes/start/start_screen.tscn"),
	Scene.SETTINGS: preload("res://scenes/start/settings_screen.tscn"),
	Scene.GRAPPLE_TEST: preload("res://scenes/grapple/grapple_test.tscn"),
	Scene.LEVEL_TEST_2: preload("res://scenes/map/LevelTest2.tscn"),
	#Scene.TWEENABLE_SHOWCASE: preload("res://scenes/examples/tweenable_showcase.tscn"),
}
func get_scene(scene:Scene) -> PackedScene:
	if scenes.has(scene):
		return scenes.get(scene)
	else: 
		print("Failed to get scene #(%s), returning scene#(%s)" % [scene, DEFAULT_SCENE])
		return scenes.get(DEFAULT_SCENE)
