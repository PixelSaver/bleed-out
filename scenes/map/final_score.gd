extends VBoxContainer

class_name FinalScore

@onready var score: RichTextLabel = $Score
@onready var high_score: RichTextLabel = $HighScore

func set_score(s: int) -> void:
	score.text = "[font_size=50][color=white][shake level=15 seed=0 rate=10]Score: " + str(s)

func set_high_score(s: int) -> void:
	high_score.text = "[font_size=50][color=white][shake level=15 seed=0 rate=10]High Score: " + str(s)
