extends Node

signal movement(move)
signal pause()
signal action_just_pressed(action)
signal action_just_released(action)
signal buffer_changed(buffer)

# Actions to observe and buffer
export(PoolStringArray) var valid_inputs = []

export(Resource) var combos
export(float) var clear_time = 0.5
export(float) var pause_time = 0.3

# To deal with input spam
export(int) var max_sequence = 8

onready var clear_timer: Timer = $ClearTimer
onready var pause_timer: Timer = $PauseTimer
onready var moves: Dictionary = combos.moves

var buffer: PoolStringArray = []

const PAUSE_ACTION = 'pause'

func _ready():
	clear_timer.one_shot = false
	reset_clear_timer()

	pause_timer.one_shot = true
	pause_timer.autostart = false


func _input(event: InputEvent):
	if buffer.size() >= max_sequence:
		clear()

	for action in valid_inputs:
		if InputMap.action_has_event(action, event):
			if Input.is_action_just_pressed(action):
				emit_signal("action_just_pressed", action)
				append(action)
				reset_pause_timer()

				var move = get_current_move()
				if move == null:
					# If this action is not combo-able, it breaks the chain and
					# restarts it.
					clear()
					append(action)
					move = get_current_move()

				if not move == null:
					emit_signal("movement", move)
					if move.terminal:
						clear()

			if Input.is_action_just_released(action):
				emit_signal("action_just_released", action)

			break



func _on_ClearTimer_timeout():
	clear()


func reset_clear_timer():
	clear_timer.start(clear_time)


func reset_pause_timer():
	pause_timer.start(pause_time)


func get_input_sequence_as_string() -> String:
	return PoolStringArray(buffer).join(" ")


# E.g. "Punch2"
func get_current_move() -> String:
	return moves.get(get_input_sequence_as_string())


func _on_PauseTimer_timeout():
	if buffer.empty():
		return

	append(PAUSE_ACTION)
	emit_signal("pause")


func append(action: String):
	buffer.append(action)
	emit_signal("buffer_changed", buffer)
	reset_clear_timer()


func clear():
	buffer = []
	emit_signal("buffer_changed", buffer)
