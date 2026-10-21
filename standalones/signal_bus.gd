extends Node

@warning_ignore("unused_signal")
signal test(test: bool)
@warning_ignore("unused_signal")
## Signal to highlight a new enemy and unhighlight the old selected enemy.
## If 'e' is null, unhighlight everything.
signal highlight_enemy(e:Enemy)
@warning_ignore("unused_signal")
## Requests a pause from the game scene
signal request_pause(should_pause: bool)
@warning_ignore("unused_signal")
signal died
