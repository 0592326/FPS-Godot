extends Spatial

func _ready():
	var globals = get_node("/root/Globals")
	globals.respawn_points = get_children()
