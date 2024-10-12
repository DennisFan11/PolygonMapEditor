extends Loadable
#region 虛方法
func _data_change(): # INFO 用來通知子類
	position = _pos
	rotation = _rot
#endregion

func _ready():
	$Polygon2D.material.set_shader_parameter("rand_time", randf_range(0.0, PI*2.0))
