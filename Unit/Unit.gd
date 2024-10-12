class_name Unit
extends Node2D

enum {PLAYER_TEAM, ENEMY_TEAM}
var _team:int

var _hp:float
var _max_hp:float

func Damage(dmg:float):
	_hp -= dmg
