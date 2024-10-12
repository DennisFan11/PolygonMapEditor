extends Unit



var blade = preload("res://Unit/Weapon/Blade/blade.tscn")
func _ready():
	Max_HP = 100.0
	HP = Max_HP
	Team = PLAYER_TEAM
	_weapon_mount = $CharacterBody2D/Marker2D
	_body = $CharacterBody2D
	Mount(blade.instantiate())



var R: float = 30.0
func _process(delta: float) -> void:
	var normal = (get_global_mouse_position() - _body.global_position).normalized()
	_weapon_mount.position = normal * R
	_weapon_mount.rotation = normal.angle()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("L_click"):
		Attack()
