class_name ObjectPlacingTool
extends StateMachine_7
var _id:int = 0


var _raycasts:Array[RayCast2D] = []

const R:float = 70.0
const Size:int = 30

func _gen_raycasts():
	for i in range(Size):
		var ray = RayCast2D.new()
		ray.target_position = Vector2(cos(PI*2.0/Size*i), sin(PI*2.0/Size*i)) * R
		_raycasts.append(ray)
		add_child(ray)

func _get_closest()-> RayCast2D:
	var _min:float = 99999.0
	var _min_ray:RayCast2D = null
	
	for i:RayCast2D in _raycasts:
		if i.is_colliding():
			var len = (i.get_collision_point()-global_position).length()
			if len <= _min:
				_min = len
				_min_ray = i
	return _min_ray


func _place():
	var _min:RayCast2D = _get_closest()
	if _min:
		var pos = _min.get_collision_point()
		var normal = _min.get_collision_normal()
		var node:Loadable = MapData.obj_scene[_id].instantiate()
		node.Init([_id, pos, normal.angle()+PI/2.0])
		ChunkLoader.instance.Object_node.add_child(node)


func _ready():
	_gen_raycasts()

func _click(type:int): # exec-once
	pass
func _clicking(type:int):
	_place()
	global_position = get_global_mouse_position()
func _finish(type:int): #exec-once
	pass

func _Idle(): # 未按下
	global_position = get_global_mouse_position()
