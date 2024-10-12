class_name Weapon
extends Node2D

enum {PLAYER_TEAM, ENEMY_TEAM}
var Team: int
var Dmg: float
var KeepTime:float
var CD: float 

var Attacking:bool ### NOTE 由Attack()進行管理其他人不得修改


func _attack_finish():
	Attacking = false
func Attack(): #NOTE 自動在每個物理偵調用 _attacking_process
	Attacking = true
	create_tween().tween_callback(_attack_finish).set_delay(CD + KeepTime)
	_attacked = []
	
	_attack_start()
	var time:float = 0.0
	while time <= KeepTime:
		time += get_physics_process_delta_time()
		await get_tree().physics_frame
		_attacking_process(get_physics_process_delta_time())
	_attack_end()
	
	_attacked = []

#region 可覆寫區

func _attack_start():
	pass
func _attacking_process(delta: float):  ### NOTE 在每個物理偵被調用
	pass
func _attack_end():
	pass

#endregion


var _attacked:Array[Unit] = [] ### NOTE 已攻擊的敵人
func _dmage_to(target:Unit):
	if target.Team != self.Team and (target not in _attacked):
		target.Damage(Dmg)
		_attacked.append(target)
