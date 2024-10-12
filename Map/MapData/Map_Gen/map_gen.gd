extends Control
var Map_size:int = 40 #pix 40
var Block_size:int = 250 #pix 250
var Scan_precision:int = 250 # 250

func _ready():
	_info_print()

func _on_save(): # NOTE 保存地圖
	_info_print()
	
	# 使用 ResourceSaver 保存资源
	var Name:String = $LineEdit.text
	if Name.is_empty():
		%Output.text = "[color=red]Need a file name !!![/color]"
		return
	var data := await _map_data_gen()
	var error = ResourceSaver.save(data, "res://Map/Pregen_maps/"+Name+".tres",0)
	if error == OK:
		%Output.text = ("Resource saved successfully!")
	else:
		%Output.text = "[color=red]Failed to save resource: [/color]"+ str(error)

func _info_print(): # NOTE 輸出地圖訊息
	%MapInfo.text = "
	[color=green][font_size=20]Map Info:[/font_size][/color]\n
	[color=green]Map_name = [/color]"+str($LineEdit.text)+".tres
	[color=green]Map_size = [/color]"+str(Map_size)+"
	[color=green]Block_size = [/color]"+str(Block_size)+"
	[color=green]Scan_precision = [/color]"+str(Scan_precision)+"
	"

func _progress_bar(i:float)->String: #NOTE 輸出bbcode進度條
	
	const length:float = 20
	var boader = true
	var s = "\nprogress: ["
	for k in range(length):
		if (k/length)<i:
			s+= "[color=green]-[/color]"
		else:
			if boader:
				s+="|"
				boader = false
			s+= "-"
	s+= "]"
	return s




#region 區塊掃描程式
@onready var sprites = [
	%Dirt,
	%Stone,
	%Coal,
	%Iorn
]
func _get_polygons(block_id:Vector2, sprite:Sprite2D)-> Array[PackedVector2Array]:
	var vec := Vector2.ONE * Map_size* Scan_precision
	sprite.visible = true
	sprite.position = vec / 2.0
	sprite.scale = vec / 512.0
	
	%Camera.offset = block_id* Scan_precision + Vector2.ONE * (Scan_precision/2.0)
	%Camera.zoom = Vector2.ONE
	%Viewport.size = Vector2.ONE * Scan_precision
	
	await RenderingServer.frame_post_draw
	var img = %Viewport.get_texture().get_image()
	sprite.visible = false
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(img, 0.9)
	#img.save_png("res://cuts/" + str(block_id.x*10000 + block_id.y)+".png")
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(), bitmap.get_size()), 5.0)
	for i in range(polygons.size()): # Re_scale
		for j in polygons[i].size():
			polygons[i][j] *= float(Block_size)/float(Scan_precision)
	return polygons
func _map_data_gen()-> MapData:
	var map_data = MapData.new()
	
	for i:Sprite2D in sprites:
		i.visible = false
	var terrain_count:int = 0
	for block_x:int in range(0, Map_size):
		for block_y:int in range(0, Map_size):
			var block_id := Vector2i(block_x, block_y)
			var block_position = block_id * Block_size
			%Output.text = \
				"[color=green]Terrain count: [/color]" + str(terrain_count) + \
				"\n[color=green]generating: [/color]"+str(block_id) +\
				_progress_bar((block_id.x*Map_size+block_id.y) / float(Map_size*Map_size))
			var block_terrain_count:int = 0
			
			for id in range(sprites.size()):
				var polygons := await _get_polygons(block_id, sprites[id])
				for i in polygons:
					var block := MapData.Block.new(id, block_position, i)
					
					map_data.Write_in_Block(block_id, block)
					terrain_count+= 1
					block_terrain_count+= 1
			if block_terrain_count == 0:
				map_data.Write_empty_data(block_id)
	for i:Sprite2D in sprites:
		i.visible = true
	
	map_data.BlockSize = Vector2.ONE * Block_size
	map_data.Map_size = Vector2.ONE * Map_size
	return map_data
#endregion
