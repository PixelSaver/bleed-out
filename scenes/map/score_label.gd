extends RichTextLabel

class_name ScoreLabel

@export var score_multiplier : float = 0.3
@onready var title_2: RichTextLabel = $Title2

func update_score(score: int) -> void:
	text = "[font_size=80][color=#c52122]Score: " + str(score) + "  "
	title_2.text = "[font_size=80][color=red]Score: " + str(score) + "  "
