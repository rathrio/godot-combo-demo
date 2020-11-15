extends Panel


onready var input_label: Label = $Input
onready var move_label: Label = $Move


func _on_CombatBuffer_buffer_changed(buffer):
	if buffer.empty():
		return

	input_label.text = PoolStringArray(buffer).join(" ")


func _on_CombatBuffer_movement(move: Move):
	move_label.text = move.id
