extends VBoxContainer

@export var slider: HSlider
@export var label_1: RichTextLabel
@export var label_2: RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider.value_changed.connect(_on_v_changed)
	var v = AudioServer.get_bus_volume_linear(
		AudioServer.get_bus_index("Master")
	)
	slider.value = v

func _on_v_changed(v: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index("Master"),
		v,
	)
	var t = "[shake level=3 rate=5]%.1f%%" % (v * 100)
	label_1.clear()
	label_1.append_text(t)
	label_2.clear()
	label_2.append_text(t)
