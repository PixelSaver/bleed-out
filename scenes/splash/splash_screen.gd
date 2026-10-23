extends PixelMenu
class_name SplashScreen

@export var reed_splash: TextureRect
@export var splash: AnimatedSprite2D
var all_t : Array[Tweenable] = []
var t: Tween 

func _ready() -> void: 
	if not Global.menu_manager:
		start_anim()

func start_anim() -> void: 
	reed_splash.modulate.a = 0.0
	AudioManager.play_sfx(AudioManager.Sound.INTRO_ACHOO, -20)
	t = default_tween().set_ease(Tween.EASE_OUT)
	t.tween_property(reed_splash, "modulate:a", 1.0, 1.0)
	t.chain()
	t.tween_property(reed_splash, "modulate:a", 0.0, 1.0)
	await t.finished
	splash.play("default")
	AudioManager.play_sfx(AudioManager.Sound.INTRO_DADOOM, -20)
	await splash.animation_finished
	Global.menu_manager.transition_to_scene(
		SceneDatabase.get_scene(SceneDatabase.Scene.START)
	)
func end_anim() -> void: 
	t = default_tween()
	t.tween_property(self, "modulate:a", 0.0, 1.0)
	await t.finished
	queue_free()
