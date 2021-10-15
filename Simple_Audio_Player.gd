extends Spatial

var audio_node = null
var should_loop = false
var globals = null

func _ready():
	audio_node = $Audio_Stream_Player
	audio_node.connect("finished", self, "sound_finished")
	audio_node.stop()

	globals = get_node("/root/Globals")


# warning-ignore:unused_argument
func play_sound(audio_stream, position=null):
	if audio_stream == null:
		print ("No audio stream passed; cannot play sound")
		globals.created_audio.remove(globals.created_audio.find(self))
		queue_free()
		return

	audio_node.stream = audio_stream

	# If you are using an AudioStreamPlayer3D, then uncomment these lines to set the position.
	if audio_node is AudioStreamPlayer3D:
		if position != null:
			audio_node.global_transform.origin = position

	audio_node.play(0.0)

func sound_finished():
	if should_loop:
		audio_node.play(0.0)
	else:
		globals.created_audio.remove(globals.created_audio.find(self))
		audio_node.stop()
		queue_free()
