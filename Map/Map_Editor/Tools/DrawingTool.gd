class_name DrawingTool
extends StateMachine_7

### NOTE : Drawing Tool 圓形繪製工具Class
### 圖形預設為圓形 由_gen_points生成 可覆寫
### 左鍵添加, 右鍵刪除 shift連線
var _id:int = 1
var _R:float = 70

func _gen_points(offset: Vector2)->PackedVector2Array:
	var arr:PackedVector2Array = []
	const point_size:float = 20
	for i in range(point_size):
		var angle:float = (i/point_size) * 2*PI
		arr.append(offset + _R * Vector2(cos(angle),  sin(angle)) )
	return arr

#region 實作層
func _sort_points(array:Array)->PackedVector2Array: # 計算順時針多邊形
	"""
	// 輸入: 2點座標 (全域座標)
	輸出: 順時針多邊形 points
	"""
	var cp = Vector2.ZERO
	for i in array:
		cp+=i
	cp/=array.size()
	var center_angle_sort = func(A:Vector2,B:Vector2) -> bool: # 中心最大角度排序 lambda (順時鐘)
		if (A-cp).angle()>=(B-cp).angle():
			return false
		return true
	array.sort_custom(center_angle_sort)# (順時鐘排序)
	return PackedVector2Array(array)

func _gen_line_points(offsetA:Vector2, offsetB:Vector2)-> PackedVector2Array:
	var shapeA = _gen_points(offsetA)
	var shapeB = _gen_points(offsetB)
	var final = []
	for pos in shapeA:
		var a = pos - offsetA
		var b = offsetB - offsetA
		if a.dot(b) < 0.0:
			final.append(pos)
	for pos in shapeB:
		var a = pos - offsetB
		var b = offsetA - offsetB
		if a.dot(b) < 0.0:
			final.append(pos)
	return _sort_points(final)
var _destroyer:Destroyer ### 破壞委託
var _poly:Polygon2D   ###  hint shape
var _area:Area2D   ### 保持在原點
var _coli:CollisionPolygon2D ### 保持在原點

func _ready(): ### NOTE 生成子節點
	_poly = Polygon2D.new()
	add_child(_poly)
	
	_area = Area2D.new()
	_coli = CollisionPolygon2D.new()
	_area.add_child(_coli)
	add_child(_area)
	
	_destroyer = Destroyer.new()
	add_child(_destroyer)
#---------------------------覆寫區-------------------------
var _first_point:Vector2 = Vector2.ZERO
var _second_point:Vector2 = Vector2.ZERO

func _clean_area():
	for i in _area.get_overlapping_areas():
		if i.is_in_group("Plant"):
			i.get_parent().queue_free()

func _click(type:int): # exec-once
	if _shift:
		_area.position =Vector2.ZERO
	else:
		_area.position = get_global_mouse_position()
	_first_point = get_global_mouse_position()
func _clicking(type:int):
	if _shift:  # 線模式, 點模式
		_second_point = get_global_mouse_position()
		_area.position =Vector2.ZERO
		_poly.position =Vector2.ZERO
		_poly.polygon = _gen_line_points(_first_point, _second_point)
		_coli.polygon = _gen_line_points(_first_point, _second_point)
	else: # point
		_area.position = get_global_mouse_position()
		_poly.position = get_global_mouse_position()
		if type == LEFT:
			_clean_area()
			_destroyer.Merge(  ### NOTE 呼叫Destroyer類中的合併方法
				_area.get_overlapping_bodies(), 
				_gen_points(get_global_mouse_position()), 
				get_global_mouse_position(),
				_id
			)
		if type == RIGHT:
			_clean_area()
			_destroyer.Clip(  ### NOTE 呼叫Destroyer類中的切割方法
				_area.get_overlapping_bodies(), 
				_gen_points(get_global_mouse_position()),
				true
			)
func _finish(type:int): #exec-once
	if _shift:  # 線模式, 點模式
		if type == LEFT:
			_clean_area()
			_destroyer.Merge(  ### NOTE 呼叫Destroyer類中的合併方法
				_area.get_overlapping_bodies(), 
				_gen_line_points(_first_point, _second_point), 
				get_global_mouse_position(),
				_id
			)
		if type == RIGHT:
			_clean_area()
			_destroyer.Clip(  ### NOTE 呼叫Destroyer類中的切割方法
				_area.get_overlapping_bodies(), 
				_gen_line_points(_first_point, _second_point)
			)
func _Idle(): # 未按下
	_poly.polygon = _gen_points(Vector2.ZERO)
	_poly.position = get_global_mouse_position()
	_coli.polygon = _gen_points(Vector2.ZERO)
#endregion
