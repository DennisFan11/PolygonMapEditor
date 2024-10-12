class_name Destructible
extends GeometryTool
#region 虛方法
func _data_change(): # INFO 用來通知子類
	pass
func _new_block(_id:int, _position:Vector2, _polygon:PackedVector2Array)->void: 
	pass # INFO 建立新的實例並加到場景樹
#endregion


### NOTE 只在自我複製和刪除時呼叫(區塊生成操作由ChunkLoader管理)
### ChunkLoader或Destructible 創建新實例應呼叫Init()

var _unloaded:bool = false # 不需要資料回報
func _chunk_loader_update(add:bool=true):
	if !_unloaded:
		if add:
			ChunkLoader.instance.Add(_position, self)
		else:
			ChunkLoader.instance.Dele(_position, self) # 沒被ChunkLoader卸載
func _exit_tree():
	_chunk_loader_update(false)


static var BlockSize: Vector2
var Busy:bool = false

var _id:int
var _position:Vector2
var _polygon:PackedVector2Array

func Set_polygon(local_polygon):
	_polygon = local_polygon
func Set_id(id):
	_id = id
func Set_position(pos):
	position = pos
	_position = pos
func Get_global_polygon():
	return _polygon_to_global(_polygon)
func Get_id():
	return _id
func Init(id, pos, local_polygon):
	Set_id(id)
	Set_position(pos)
	Set_polygon(local_polygon)
	_chunk_loader_update(true)
func unload(): ### 不需要資料回報
	_unloaded = true
	queue_free()
	return [_id, _position, _polygon]

#func Get_polygon():
	#return _polygon_to_global(_polygon)

func Clip(global_polygon:PackedVector2Array)-> float:
	var value = _clip(_polygon_to_local(global_polygon))
	_data_change()
	return value

func Merge(global_polygon:PackedVector2Array)-> float:
	var value = _merge(_polygon_to_local(global_polygon))
	_data_change()
	return value

func After_Optimize_Clip(global_polygon:PackedVector2Array)-> float:
	var value = _after_optimize_clip(_polygon_to_local(global_polygon))
	_data_change()
	return value





#region  實作
#region Tools (to_global, to_local, _group_spawn)
func _pos_polygon_to_local(global_polygon, pos)-> PackedVector2Array:
	var arr:PackedVector2Array = []
	for i in global_polygon:
		arr.append(i-pos)
	return arr   ### WARNING
func _polygon_to_global(local_polygon:PackedVector2Array)-> PackedVector2Array:
	var arr:PackedVector2Array = []
	for i in local_polygon:
		arr.append(to_global(i))
	return arr
func _polygon_to_local(global_polygon:PackedVector2Array)-> PackedVector2Array:
	var arr:PackedVector2Array = []
	for i in global_polygon:
		arr.append(to_local(i))
	return arr
func _group_spawn(id:int, pos:Vector2, polygons:Array[PackedVector2Array]):
	for polygon:PackedVector2Array in polygons:
		_new_block(id, pos, polygon)
#endregion


var _split_timer:Timer
var _optimize_timer:Timer

func _gen_timers():
	_split_timer = Timer.new()
	add_child(_split_timer)
	_split_timer.timeout.connect(_self_split)
	_split_timer.one_shot = true
	
	_optimize_timer = Timer.new()
	add_child(_optimize_timer)
	_optimize_timer.timeout.connect(_self_optimize)
	_optimize_timer.one_shot = true


func _set_split_timer():
	if _split_timer:
		_split_timer.start(1.0)
	else:
		_gen_timers()
func _set_optimize_timer():
	if _optimize_timer:
		_optimize_timer.start(1.0)
	else:
		_gen_timers()



func _self_split(): # 區塊優化
	var BLOCK_SIZE = BlockSize.x
	var arr_pos = []
	var arr_poly = []
	var R= 8 # 擴張涉及的區塊 越大的單次擴張需要越大的值
	for x in range(-R,R+1): # 初始化 座標及多邊形陣列
		for y in range(-R,R+1):
			var pos = Vector2(x,y)*BLOCK_SIZE + _position
			arr_pos.append(pos)
			arr_poly.append(PackedVector2Array([
				Vector2(pos.x,pos.y),
				Vector2(pos.x+BLOCK_SIZE,pos.y),
				Vector2(pos.x+BLOCK_SIZE,pos.y+BLOCK_SIZE),
				Vector2(pos.x,pos.y+BLOCK_SIZE)
			]))
	# 相交生成
	for i in range(arr_pos.size()):
		var need_polygon = Geometry2D.intersect_polygons(_polygon_to_global(_polygon), arr_poly[i])
		for j in range(need_polygon.size()):
			need_polygon[j] = _pos_polygon_to_local(need_polygon[j], arr_pos[i])
		_group_spawn(_id, arr_pos[i], need_polygon)
		#if need_polygon.size()!= 0:
			#print("gen: ",arr_pos[i])
	#print("-------------")
	queue_free()
	return

var last_origin:PackedVector2Array = []
func _self_optimize():
	Set_polygon(VertexOptimization(_polygon, last_origin, BlockSize))
	last_origin = []
	_data_change()

func _clip(local_polygon:PackedVector2Array)-> float:
	var origin = _polygon
	var clipped := Geometry2D.clip_polygons(origin, local_polygon)
	if clipped.size() == 0:
		queue_free()
		return Calculate_polygon_area(origin, local_polygon)
	
	for i in range(clipped.size()):# 全體頂點優化
		clipped[i] = VertexOptimization(clipped[i], origin, BlockSize)
	clipped = Merge_hole_polygon(clipped) # 合併有孔多邊形
	Set_polygon(clipped.pop_front()) # 重設自身多邊形
	_group_spawn(_id, _position, clipped) # 實例化剩餘多邊形
	return Calculate_polygon_area(origin, local_polygon) # 面積計算

func _merge(local_polygon:PackedVector2Array)->float:
	var origin = _polygon
	var merged = Geometry2D.merge_polygons(origin, local_polygon)
	if merged.size() == 0:
		queue_free()
		return Calculate_polygon_area(origin, local_polygon)
	
	#for i in range(merged.size()):# 全體頂點優化
		#merged[i] = VertexOptimization(merged[i], origin, BlockSize)
	### BUG 沒有帶孔多邊形合併
	Set_polygon(merged.pop_front()) # 重設自身多邊形
	_group_spawn(_id, _position, merged) # 實例化剩餘多邊形
	
	### ATTENTION Self Split timer start
	_set_split_timer()
	
	return Calculate_polygon_area(origin, local_polygon) # 面積計算

func _after_optimize_clip(local_polygon:PackedVector2Array)-> float: # TEST 高壓場景用
	Busy = true
	var origin = _polygon
	var clipped = Geometry2D.clip_polygons(origin, local_polygon)
	if clipped.size() == 0:
		queue_free()
		return Calculate_polygon_area(origin, local_polygon)
	clipped = Merge_hole_polygon(clipped) # 合併有孔多邊形
	Set_polygon(clipped.pop_front()) # 重設自身多邊形
	_group_spawn(_id, _position, clipped) # 實例化剩餘多邊形
	
	### ATTENTION Self optimize timer start
	if last_origin.size() == 0:
		last_origin = origin
	_set_optimize_timer()
		
	Busy = false
	
	return Calculate_polygon_area(origin, local_polygon) # 面積計算

#endregion

#
