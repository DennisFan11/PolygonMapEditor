class_name Unit
extends Node2D

enum {PLAYER_TEAM, ENEMY_TEAM}
var Team:int

var HP:float
var Max_HP:float

func Damage(dmg:float):
	HP -= dmg

var _body:Node2D
var _weapon_mount:Marker2D
var _weapon:Weapon
func Mount(weapon:Weapon):
	if _weapon_mount:
		if _weapon:
			_weapon.queue_free()
		_weapon_mount.add_child(weapon)
		_weapon = weapon
	else:
		assert(false, "Need to set a Maeker2D to _weapon_mount, from Class Unit")
func Attack():
	_weapon.Attack()
