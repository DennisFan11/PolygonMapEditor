extends ChunkLoader
var player_pos:Vector2 = Vector2.ZERO
func _ready():
	Load("test0")
	%BlockGrid.material.set_shader_parameter("BlockSize", ChunkLoader.BlockSize)
func _process(delta):
	SetPosition(player_pos)
