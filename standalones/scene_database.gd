extends Node

const DEFAULT_SCENE = Scene.START
enum Scene {
	START,
	GAME,
	SPLASH,
}

var scenes = {
	Scene.START: preload("res://scenes/start/start_screen.tscn"),
	Scene.GAME: preload("res://scenes/map/game.tscn"),
	Scene.SPLASH: preload("res://scenes/splash/splash_screen.tscn"),
	#Scene.TWEENABLE_SHOWCASE: preload("res://scenes/examples/tweenable_showcase.tscn"),
}
func get_scene(scene:Scene) -> PackedScene:
	if scenes.has(scene):
		return scenes.get(scene)
	else: 
		print("Failed to get scene #(%s), returning scene#(%s)" % [scene, DEFAULT_SCENE])
		return scenes.get(DEFAULT_SCENE)
