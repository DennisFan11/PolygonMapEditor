extends Weapon
func _ready() -> void:
	Team = 0
	KeepTime = 0.1
	Dmg = 10.0
	CD = 1.0

func _process(delta: float) -> void:
	$Area2D/ColorRect.material.set_shader_parameter("angle", rotation-PI/2.0)




var _time = 0.0
func _attack_start():
	$Path2D/PathFollow2D.progress_ratio = 0.0
	$Area2D.position = Vector2.ZERO
func _attacking_process(delta: float):  ### NOTE 在每個物理偵被調用
	_time += delta
	$Path2D/PathFollow2D.progress_ratio = _time / KeepTime
	_update_position()
func _attack_end():
	$Path2D/PathFollow2D.progress_ratio = 0.0
	$Area2D.position = Vector2.ZERO

func _update_position():
	$Area2D.position = $Path2D/PathFollow2D.position
