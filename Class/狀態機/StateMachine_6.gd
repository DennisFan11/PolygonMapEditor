extends Node2D 
class_name StateMachine_7
### NOTE 左鍵及右鍵 狀態機 覆寫方法來存取
enum {L_CLICK, L_CLICKING, L_FINISH, IDLE, R_CLICK, R_CLICKING, R_FINISH, }
enum {LEFT, RIGHT}
#--------------------------可覆寫區-------------------------
func _click(type:int): # exec-once
	pass
func _clicking(type:int):
	pass
func _finish(type:int): #exec-once
	pass

func _Idle(): # 未按下
	pass
	
#--------------------------內部實作---------------------------


#region 內部實作
var _state = IDLE
func _physics_process(delta):
	match _state:
		L_CLICK: # 左鍵按下 (建造開始)
			_state = L_CLICKING
			_click(LEFT)
		L_CLICKING: # 左鍵持續下壓 ()
			_clicking(LEFT)
		L_FINISH: # 左鍵彈起 (建造完成)
			_state = IDLE
			_finish(LEFT)
			
		IDLE: # 左鍵未按下 (默認狀態)
			_Idle()
			
		R_CLICK:
			_state = R_CLICKING
			_click(RIGHT)
		R_CLICKING:
			_clicking(RIGHT)
		R_FINISH:
			_state = IDLE
			_finish(RIGHT)
var _shift:bool = false
func _unhandled_input(event):
	if event.is_action_pressed("L_click"):
		_state = L_CLICK
	elif event.is_action_released("L_click"):
		_state = L_FINISH
	elif event.is_action_pressed("R_click"):
		_state = R_CLICK
	elif event.is_action_released("R_click"):
		_state = R_FINISH
	elif event.is_action_pressed("shift"):
		_shift = true
	elif event.is_action_released("shift"):
		_shift = false
#endregion
