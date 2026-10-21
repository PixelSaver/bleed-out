extends Node
class_name AudioManager
enum Sound {
	DASH,
	LAZER,
	GRAPPLE_1,
	GRAPPLE_2,
	WATERFALL_ISOLATED,
	WATERFALL_LOOP,
	WATERFALL_CHOIR,
}
const sounds: Dictionary[Sound, AudioStream] = {
	Sound.DASH: preload("res://assets/sfx/blood_dash.wav"),
	Sound.LAZER: preload("res://assets/sfx/eyeball_lazer_charge.wav"),
	Sound.GRAPPLE_1: preload("res://assets/sfx/grapple_attach_1.smaller.wav"),
	Sound.GRAPPLE_2: preload("res://assets/sfx/grapple_attatch_2.wav"),
	Sound.WATERFALL_ISOLATED: preload("res://assets/sfx/holy_waterfall_bg_isolated.wav"),
	Sound.WATERFALL_LOOP: preload("res://assets/sfx/holy_waterfall_bg_loop.wav"),
	Sound.WATERFALL_CHOIR: preload("res://assets/sfx/holy_waterfall_bg_choir.wav"),
}

func get_audio_stream(s:Sound) -> AudioStream:
	var out = sounds.get(s)
	if out:
		return out
	else:
		return AudioStream.new()

func play_sfx(sound: Sound, volume_db: float = 0.0) -> void:
	if not sounds.has(sound):
		push_warning("Unknown sound effect: " + Sound.keys()[sound])
		return

	var player := AudioStreamPlayer.new()
	player.stream = get_audio_stream(sound)
	player.volume_db = volume_db
	player.bus = "SFX"

	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
