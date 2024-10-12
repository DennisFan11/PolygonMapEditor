extends Node2D


func _ready():
	$CanvasLayer/Control/Node2D/SubViewportContainer/SubViewport/TerrainEditor_ui.TargetNode = \
		self

func _process(delta):
	var vec = Input.get_vector("a", "d", "w", "s")
	%Camera.offset += vec * 1000.0 * delta
	$CanvasGroup/ChunkLoad.player_pos = %Camera.offset
	%BlockGrid.position = %Camera.offset - get_viewport_rect().size

func _unhandled_input(event):
	if event.is_action_pressed("scroll_down"):
		%Camera.zoom *= 0.9
	elif event.is_action_pressed("scroll_up"):
		%Camera.zoom *= 1.1
func Terrain_Debug(debug:bool):
	$CanvasGroup.material.set_shader_parameter("DEBUG_MODE", debug)
