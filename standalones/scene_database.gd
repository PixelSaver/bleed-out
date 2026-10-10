extends Node

const DEFAULT_SCENE = Scene.START
enum Scene {
	START,
	TWEENABLE_SHOWCASE,
}

var scenes = {
	Scene.START: preload("res://scenes/examples/start_screen.tscn"),
	Scene.TWEENABLE_SHOWCASE: preload("res://scenes/examples/tweenable_showcase.tscn"),
}
func get_scene(scene:Scene) -> PackedScene:
	if scenes.has(scene):
		return scenes.get(scene)
	else: 
		print("Failed to get scene #(%s), returning scene#(%s)" % [scene, DEFAULT_SCENE])
		return scenes.get(DEFAULT_SCENE)
