extends Control



var TargetNode:Node2D
var Tool:StateMachine_7
func _on_circle_pressed():
	if Tool:
		Tool.queue_free()
	Tool = DrawingToolCircle.new()
	TargetNode.add_child(Tool)


func _on_square_pressed():
	if Tool:
		Tool.queue_free()
	Tool = DrawingToolSquare.new()
	TargetNode.add_child(Tool)

func _on_grass_pressed():
	if Tool:
		Tool.queue_free()
	Tool = ObjectPlacingTool.new()
	TargetNode.add_child(Tool)


func _process(delta):
	$Panel/RichTextLabel.text = "[color=green][font_size=20]FPS: "+\
		str(Performance.get_monitor(Performance.TIME_FPS)) +\
		"[/font_size][/color]"




### NOTE 地形畫筆設定
func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	if Tool:
		Tool._id = index


var _Terrain_Debug_mode:bool = false
### NOTE Debug 畫面設定
func _on_visual_item_clicked(index, at_position, mouse_button_index):
	match index:
		0:
			_Terrain_Debug_mode = !_Terrain_Debug_mode
			TargetNode.Terrain_Debug(_Terrain_Debug_mode)
		1: # 增加 Loader_radius
			ChunkLoader.Loader_radius += 1
		2: # 減少 Loader_radius
			ChunkLoader.Loader_radius -= 1







#
