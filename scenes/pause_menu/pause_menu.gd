extends Control

@onready var resume_button: Button = %"Resume Button"
@onready var quit_button: Button = %"Quit Button"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	resume_button.pressed.connect(resume)
	quit_button.pressed.connect(get_tree().quit)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause()
		get_viewport().set_input_as_handled()

func pause() -> void:
	get_tree().paused = true
	show()
	resume_button.grab_focus()

func resume() -> void:
	get_tree().paused = false
	hide()
