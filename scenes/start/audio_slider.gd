extends VBoxContainer

@export var bus := "Master"
@export var slider: HSlider
@export var label_1: RichTextLabel
@export var label_2: RichTextLabel
@export var hover_sfx_interval := 0.3
var hover_sfx_cooldown := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider.value_changed.connect(_on_v_changed)
	var v = AudioServer.get_bus_volume_linear(
		AudioServer.get_bus_index(bus)
	)
	slider.value = v

func _on_v_changed(v: float) -> void:
	AudioServer.set_bus_volume_linear(
		AudioServer.get_bus_index(bus),
		v,
	)
	var t = "[shake level=3 rate=5]%.1f%%" % (v * 100)
	label_1.clear()
	label_1.append_text(t)
	label_2.clear()
	label_2.append_text(t)

	if hover_sfx_cooldown <= 0.0:
		AudioManager.play_sfx(AudioManager.Sound.UI_HOVER, -10, 0.0, bus)
		hover_sfx_cooldown = hover_sfx_interval

func _process(delta: float) -> void:
	hover_sfx_cooldown = maxf(0.0, hover_sfx_cooldown - delta)
