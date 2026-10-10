@tool
extends EditorScript

func _get_tweenables(node: Node) -> Array[Tweenable]:
	var result: Array[Tweenable] = []
	for c in node.get_children():
		if c is Tweenable:
			result.append(c)
	return result

func _apply_random(child: Tweenable, dirs: Array) -> void:
	child.direction = dirs[randi_range(0, dirs.size() - 1)]
	child.distance = randf_range(0, 200)

func _run() -> void:
	randomize()

	var editor := EditorInterface
	var selection: Array = editor.get_selection().get_selected_nodes()
	var root := editor.get_edited_scene_root()
	var undo_redo = editor.get_editor_undo_redo()

	if selection.is_empty() or root == null:
		return

	var dirs = [
		Vector2.DOWN,
		Vector2.UP,
		Vector2.LEFT,
		Vector2.RIGHT
	]

	undo_redo.create_action("Randomize Tweenables")

	for parent in selection:
		if not parent is Node: continue

		# get existing Tweenables
		var tweenables := _get_tweenables(parent)
		# IF none exist -> create one
		if tweenables.is_empty():
			var child := Tweenable.new()
			child.name = "Tweenable"

			_apply_random(child, dirs)

			undo_redo.add_do_method(parent, "add_child", child)
			undo_redo.add_do_method(child, "set_owner", root)
			undo_redo.add_do_reference(child)

			undo_redo.add_undo_method(parent, "remove_child", child)
			undo_redo.add_undo_reference(child)

		# IF exist -> randomize them
		else:
			for t in tweenables:
				_apply_random(t, dirs)

	undo_redo.commit_action()
	print("Tweenables randomized")
