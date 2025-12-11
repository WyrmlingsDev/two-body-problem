extends AudioStreamPlayer

func _ready() -> void:
	connect("finished", Callable(self, "_on_music_finished"))
	autoplay = true
	
func change_song(source: Resource):
	stream = source
	play()

func _on_music_finished():
	play()
