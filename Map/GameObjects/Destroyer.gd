class_name Destroyer
extends Node
func Clip(
		bodies:Array[Node2D], 
		global_polygon:PackedVector2Array,
		after:bool = false
	):
	_clip(bodies, global_polygon, after)

func Merge(
		bodies:Array[Node2D], 
		global_polygon:PackedVector2Array,
		global_pos:Vector2,
		id:int
	):
	_merge(bodies, global_polygon, id, global_pos)

#region 實作

func _polygon_to_global(polygon:PackedVector2Array,global_pos:Vector2)-> PackedVector2Array:
	var arr:PackedVector2Array = []
	for i in polygon:
		arr.append( global_pos + i )
	return arr
func _polygon_to_local(polygon:PackedVector2Array,global_pos:Vector2)-> PackedVector2Array:
	var arr:PackedVector2Array = []
	for i in polygon:
		arr.append( i-global_pos )
	return arr


### 基於碰撞物件切割
func _clip(bodies:Array[Node2D], global_polygon:PackedVector2Array, after:bool = false):
	for i in bodies:
		if i.is_in_group("Destructible"):
			i = i.get_parent() as Destructible
			if after:
				i.After_Optimize_Clip(global_polygon)
			else:
				i.Clip(global_polygon)
var _block_scene = preload("res://Map/GameObjects/BlockScene/Block.tscn")

func _merge(bodies:Array[Node2D] , global_polygon:PackedVector2Array, id:int, global_pos):
	### NOTE 合併所有相同id物件, 並切割不同id物件, 時間過後自分裂
	var marge_node:Destructible = null
	for i in range(bodies.size()):
		if bodies[i].is_in_group("Destructible") and bodies[i].get_parent().Get_id() == id:
			marge_node = bodies.pop_at(i).get_parent()
			marge_node.Merge(global_polygon)
			break
	if !marge_node: # 相同id實例不存在
		marge_node = _block_scene.instantiate()
		marge_node.Init(id, snapped(global_pos, Vector2(ChunkLoader.BlockSize)),
			_polygon_to_local(global_polygon, snapped(global_pos, Vector2(ChunkLoader.BlockSize))))
		ChunkLoader.instance.add_child(marge_node)
		marge_node.Merge(PackedVector2Array()) ### NOTE 手動觸發自分裂
		
	for i in bodies:
		
		if i.is_in_group("Destructible"):
			var block:Destructible = i.get_parent()
			if block.Get_id() == id:
				marge_node.Merge(block.Get_global_polygon())
				block.queue_free()
			else:
				block.Clip(global_polygon)
	
#endregion
