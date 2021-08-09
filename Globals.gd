extends Node

var mouse_sensitivity = 0.08
var joypad_sensitivity = 2

# ------------------------------------
# All the GUI/UI-related variables

var canvas_layer = null # Allows GUI/UI to always stay on top.

const DEBUG_DISPLAY_SCENE = preload("res://Debug_Display.tscn") # Loads the debug scene.
var debug_display = null

# ------------------------------------

func _ready():
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func load_new_scene(new_scene_path):
	get_tree().change_scene(new_scene_path)

func set_debug_display(display_on):
	if display_on == false:
		if debug_display != null:
			debug_display.queue_free()
			debug_display = null
	else:
		if debug_display == null:
			debug_display = DEBUG_DISPLAY_SCENE.instance()
			canvas_layer.add_child(debug_display)
