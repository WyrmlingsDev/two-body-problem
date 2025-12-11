extends RichTextLabel

var speed := 0.05
var timer := 0.0
var full_text := ""

func _ready():
	full_text = Global.dialogues[Global.deaths]
	visible_characters = 0
	text = full_text

func _process(delta):
	if visible_characters >= full_text.length():
		return

	timer += delta
	if timer >= speed:
		timer -= speed
		visible_characters += 1
