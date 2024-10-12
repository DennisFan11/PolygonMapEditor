class_name ChunkLoader
extends Node2D
### NOTE 區塊加載器 ( 加載地圖後,每偵更新位置 )

var _map:MapData

static var BlockSize:Vector2
static var MapSize:Vector2
static var instance:ChunkLoader
static var Object_node:Node2D
func Load(str:String):
	_map = ResourceLoader.load("res://Map/Pregen_maps/"+str+".tres", "MapData")
	_map_loaded = true
	BlockSize = _map.BlockSize
	MapSize = _map.Map_size
	instance = self
	Destructible.BlockSize = BlockSize
func SetPosition(new_position:Vector2)->void: # 需要每偵調用
	_chunk_update(new_position)

var _map_loaded:bool = false
var _block_scene = preload("res://Map/GameObjects/BlockScene/Block.tscn")
var _loaded_chunk = {} # Vector2i: Array[Destructible]

var _object_chunk = {} # Vector2i: Array[Loadable]



func Add(global_pos:Vector2, instance:Destructible): ### NOTE 供可破壞物件存取
	var map_pos = Vector2i( global_pos/BlockSize )
	if _loaded_chunk.has(map_pos):
		_loaded_chunk[map_pos].append(instance)
	else:
		_loaded_chunk[map_pos] = [instance]

func ObjAdd(global_pos:Vector2, instance:Loadable): ### NOTE 通用物件
	var map_pos = Vector2i( global_pos/BlockSize )
	if _object_chunk.has(map_pos):
		_object_chunk[map_pos].append(instance)
	else:
		_object_chunk[map_pos] = [instance]
	

### ATTENTION BUG 方塊刪除後回朔 
func Dele(global_pos:Vector2, instance:Destructible): ### NOTE 供可破壞物件存取
	var map_pos = Vector2i( global_pos/BlockSize )
	for i in range(_loaded_chunk[map_pos].size()):
		if (_loaded_chunk[map_pos][i] == instance):
			_loaded_chunk[map_pos].remove_at(i)
			break

func ObjDele(global_pos:Vector2, instance:Loadable):  ### NOTE 通用物件
	var map_pos = Vector2i( global_pos/BlockSize )
	for i in range(_object_chunk[map_pos].size()):
		if (_object_chunk[map_pos][i] == instance):
			_object_chunk[map_pos].remove_at(i)
			break


#region 實作層
func _gen_need_chunk(global_pos:Vector2, block_size:Vector2, R:int)->Array[Vector2i]:
	### NOTE 生成需要的chunk
	var arr:Array[Vector2i] = []
	var map_pos = Vector2i( global_pos/block_size )
	for x in range(-R,R+1,1):
		for y in range(-R, R+1,1):
			var pos = map_pos + Vector2i(x,y)
			if (pos.x >= 0 and pos.y >= 0) and (pos.x < MapSize.x and pos.y < MapSize.y):
				arr.append(pos)
	return arr

func _load_chunk(map_pos:Vector2i)-> void: # NOTE 從_map中讀取資料並建立實例
	#_loaded_chunk[map_pos] = [] # TBD 預設必須為空 將引用寫入
	var data_array = _map.terrain[map_pos] # 至存檔取出資料
	for i in data_array:
		var node:Destructible = _block_scene.instantiate()
		node.Init(i[0], i[1], i[2]) # 包含將引用寫入_loaded_chunk
		add_child(node)
	### ================== NOTE 通用物件層 ==================
	if !_map.objs.has(map_pos):
		_map.objs[map_pos] = [] 
	for obj in _map.objs[map_pos]:
		var node:Loadable = _map.obj_scene[obj[0]].instantiate()
		node.Init(obj)
		Object_node.add_child(node)

func _unload_chunk(map_pos:Vector2i)-> void: # NOTE 釋放並將資料存回_map
	_map.terrain[map_pos] = [] # 清除存檔
	for i:Destructible in _loaded_chunk[map_pos]:
		_map.terrain[map_pos].append(i.unload()) # 寫入新資料 & queue_free
	_loaded_chunk.erase(map_pos)
	### ================== NOTE 通用物件層 ==================
	_map.objs[map_pos] = []
	if !_object_chunk.has(map_pos):
		return 
	for obj:Loadable in _object_chunk[map_pos]:
		_map.objs[map_pos].append(obj.unload())
	_object_chunk.erase(map_pos)


static var Loader_radius:int = 3: # NOTE 區塊加載半徑
	set(new):
		Loader_radius = clampi(new, 1, 30)


func _chunk_update(new_pos:Vector2):
	if !_map_loaded: # NOTE 地圖未載入
		return

	var R:int = Loader_radius
	var map_size:Vector2  = _map.Map_size # TBD
	var block_size:Vector2 = _map.BlockSize
	
	var need_array = _gen_need_chunk(new_pos, block_size, R)
	#print("need_array:", need_array)
	#print("_loaded_chunk:", _loaded_chunk)
	for pos in need_array: # NOTE 加載區塊
		if pos in _loaded_chunk:
			### 已存在 
			pass
		else:
			### load
			_load_chunk(pos)
	for pos in _loaded_chunk.keys(): # NOTE 卸載區塊
		if pos in need_array:
			### 已存在 
			pass
		else:
			### unload
			_unload_chunk(pos)


#endregion







#
