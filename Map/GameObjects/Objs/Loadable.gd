class_name Loadable
extends Node2D
#region 虛方法
func _data_change(): # INFO 用來通知子類
	pass
#endregion

var _id:int
var _pos:Vector2
var _rot:float
var _unloaded = false # 是否已被ChunkLoader卸載

func _chunk_loader_update(add:bool=true):
	if !_unloaded:
		if add:
			ChunkLoader.instance.ObjAdd(_pos, self)
		else:
			ChunkLoader.instance.ObjDele(_pos, self) # 沒被ChunkLoader卸載

func Init(data_array:Array): # NOTE 自動更新ChunkLoader
	self._id = data_array[0]
	self._pos = data_array[1]
	self._rot = data_array[2]
	_data_change()
	_chunk_loader_update(true)

func _exit_tree():
	_chunk_loader_update(false)

func unload():
	_unloaded = true
	queue_free()
	return [_id, _pos, _rot]















#
