class_name MapData
extends Resource
@export var terrain:Dictionary = {}
###NOTE {Vector2i : Array[Block_data]}
###Block_data{int Vector2 PackedVector2Array}
@export var Map_size:Vector2i # 地圖尺寸
@export var BlockSize:Vector2i # 方塊尺寸

func Write_in_Block(id:Vector2i, new_block:Block): # 添加方塊的接口
	var new:Array = []
	if terrain.has(id):
		var old:Array = terrain[id]
		for i in old: # 切割所有舊方塊
			var new_polygons = Geometry2D.clip_polygons(i[2], new_block.polygon)
			for polygon in new_polygons:
				var data = [i[0], i[1], polygon]
				new.append(data)
	new.append([new_block.id, new_block.position, new_block.polygon]) # 添加新方塊
	terrain[id] = new
func Write_empty_data(id:Vector2i): # 寫入空list
	if !terrain.has(id):
		terrain[id] = []


class Block: 
	func _init(id:int, position:Vector2, polygon:PackedVector2Array):
		self.id = id
		self.position = position
		self.polygon = polygon
	var id:int
	var position:Vector2
	var polygon:PackedVector2Array



@export var objs:Dictionary = {}
###NOTE {Vector2i : Array[id, DataArray]}
static var obj_scene:Array[PackedScene] = [
	preload("res://Map/GameObjects/Objs/Plant/Grass/grass.tscn")
]
