extends Node

enum Sound {
	DASH,
	DEATH,
	EYEBALL_SHIELD_BREAK,
	FROG_FIRE_1,
	FROG_FIRE_2,
	GRAPPLE_1,
	GRAPPLE_2,
	HURT_1,
	HURT_2,
	HURT_3,
	INTRO_ACHOO,
	INTRO_DADOOM,
	LAZER_CHARGE,
	LAZER_FIRE,
	PARRY,
	PARRY_SUCCESS,
	UI_CLICK,
	UI_HOVER,
	WATERFALL_ISOLATED,
	WATERFALL_LOOP,
	WATERFALL_CHOIR,
	HEAL,
	BLOOD_EXPLODE,
	DADOOM,
	ACHOO
}
const sounds: Dictionary[Sound, AudioStream] = {
	Sound.DASH: preload("res://assets/sfx/blood_dash.mp3"),
	Sound.DEATH: preload("res://assets/sfx/death_sound.wav"),
	Sound.EYEBALL_SHIELD_BREAK: preload("res://assets/sfx/eyeball_shield_break.wav"),
	Sound.FROG_FIRE_1: preload("res://assets/sfx/frog_fire1.wav"),
	Sound.FROG_FIRE_2: preload("res://assets/sfx/frog_fire2.ogg"),
	Sound.GRAPPLE_1: preload("res://assets/sfx/grapple_attatch_1_smaller.mp3"),
	Sound.GRAPPLE_2: preload("res://assets/sfx/grapple_attatch_2.mp3"),
	Sound.HURT_1: preload("res://assets/sfx/hurt1.mp3"),
	Sound.HURT_2: preload("res://assets/sfx/hurt2.mp3"),
	Sound.HURT_3: preload("res://assets/sfx/hurt3.mp3"),
	Sound.INTRO_ACHOO: preload("res://assets/sfx/achoointro.wav"),
	Sound.INTRO_DADOOM: preload("res://assets/sfx/dadoomintro.wav"),
	Sound.LAZER_CHARGE: preload("res://assets/sfx/eyeball_lazer_charge.mp3"),
	Sound.LAZER_FIRE: preload("res://assets/sfx/lazer_fire.wav"),
	Sound.PARRY: preload("res://assets/sfx/parry.wav"),
	Sound.PARRY_SUCCESS: preload("res://assets/sfx/parry_success.wav"),
	Sound.UI_CLICK: preload("res://assets/sfx/ui_click.wav"),
	Sound.UI_HOVER: preload("res://assets/sfx/ui_hover.wav"),
	Sound.WATERFALL_ISOLATED: preload("res://assets/sfx/holy_waterfall_bg_isolated.wav"),
	Sound.WATERFALL_LOOP: preload("res://assets/sfx/holy_waterfall_bg_loop.wav"),
	Sound.WATERFALL_CHOIR: preload("res://assets/sfx/holy_waterfall_bg_choir.wav"),
	Sound.HEAL: preload("res://assets/sfx/healonKill v1.wav"),
	Sound.BLOOD_EXPLODE: preload("res://assets/sfx/EnemyBloodExplode(not_scary).wav"),
	Sound.DADOOM: preload("res://assets/sfx/dadoomIntro v3.wav"),
	Sound.ACHOO: preload("res://assets/sfx/NosebleedSplashIntro.wav"),
}

var TITLE_MUSIC: AudioStreamWAV = preload("res://assets/music/Track 1 BleedOut Intro Oct21.wav")
var GAME_MUSIC: AudioStreamWAV = preload("res://assets/music/Track 1 BleedOut Oct21.wav")

var music_player: AudioStreamPlayer
var music_tween: Tween

@export var music_volume_db: float = -1.0

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.name = "MusicPlayer"
	add_child(music_player)
	music_player.volume_db = music_volume_db

	TITLE_MUSIC.loop_mode = AudioStreamWAV.LOOP_FORWARD
	TITLE_MUSIC.loop_begin = 0
	TITLE_MUSIC.loop_end = roundi(TITLE_MUSIC.get_length() * TITLE_MUSIC.mix_rate)

	GAME_MUSIC.loop_mode = AudioStreamWAV.LOOP_FORWARD
	GAME_MUSIC.loop_begin = roundi(TITLE_MUSIC.get_length() / 2.0 * GAME_MUSIC.mix_rate)
	GAME_MUSIC.loop_end = roundi(GAME_MUSIC.get_length() * GAME_MUSIC.mix_rate)

func get_audio_stream(s:Sound) -> AudioStream:
	var out = sounds.get(s)
	if out:
		return out
	else:
		return AudioStream.new()

var sfx_counter := 0
func play_sfx(sound: Sound, volume_db: float = 0.0, start_pos: float = 0.0, bus: String="SFX") -> void:
	if not sounds.has(sound):
		push_warning("Unknown sound effect: " + Sound.keys()[sound])
		return

	var player := AudioStreamPlayer.new()
	player.bus = bus
	player.stream = get_audio_stream(sound)
	player.volume_db = volume_db
	player.name = "%s_%d" % [Sound.keys()[sound], sfx_counter]
	sfx_counter += 1

	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	player.seek(start_pos)
## Like sfx but adds it to the node itself
func play_sfx_2d(node:Node2D, sound: Sound, volume_db: float = 0.0, start_pos: float = 0.0) -> void:
	if not sounds.has(sound):
		push_warning("Unknown sound effect: " + Sound.keys()[sound])
		return
	var player = AudioStreamPlayer2D.new()
	player.bus = "SFX"
	player.stream = get_audio_stream(sound)
	player.volume_db = volume_db
	player.name = "%s_%d" % [Sound.keys()[sound], sfx_counter]
	sfx_counter += 1

	node.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	player.seek(start_pos)

func kill_sfx(sound: Sound) -> void:
	var s = Sound.keys()[sound]
	for child in get_children():
		if child.name.contains(s):
			child.queue_free()

func play_title_music() -> void:
	if music_player.playing and music_player.stream == TITLE_MUSIC:
		return
	cancel_music_fade()

	music_player.stream = TITLE_MUSIC
	music_player.play()


func transition_to_game_music() -> void:
	cancel_music_fade()

	if music_player.playing and music_player.stream == GAME_MUSIC:
		return

	var pos = fposmod(music_player.get_playback_position(), TITLE_MUSIC.get_length() / 2.0) if music_player.playing else 0.0

	music_player.stream = GAME_MUSIC
	music_player.play(pos)


func stop_music(duration: float = 2.0) -> void:
	if music_tween and music_tween.is_running():
		music_tween.kill()

	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", -80.0, duration)
	await music_tween.finished

	music_player.stop()
	music_player.volume_db = music_volume_db
	
func cancel_music_fade() -> void:
	if music_tween and music_tween.is_running():
		music_tween.kill()
	music_player.volume_db = music_volume_db
