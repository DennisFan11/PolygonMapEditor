extends Destructible


#region override
func _data_change(): # INFO 用來通知子類
	_update()

var Scene = preload("res://Map/GameObjects/BlockScene/Block.tscn")
func _new_block(_id:int, _position:Vector2, _polygon:PackedVector2Array)->void:
	### INFO 建立新的實例並加到場景樹
	var node:Destructible = Scene.instantiate()
	node.Init(_id, _position, _polygon)
	ChunkLoader.Terrain_node.add_child(node)
#endregion



func _ready():
	_update()

func _update():
	%colli.set_deferred("polygon", _polygon)
	%TestLine.points = _polygon
	%polygon.color = map[_id]
	
	%polygon.polygon = _polygon
	
const colors = {
	DIRT=Color(0.68, 0.36, 0.24),
	STONE=Color(0.5,0.5,0.5),
	COPPER=Color(0.914, 0.6, 0.3),
	IORN=Color(0.2, 0.2, 0.2),
	COAL=Color(0.1, 0.1, 0.1)
}
var map = [colors.DIRT, colors.STONE, colors.IORN, colors.COAL]
