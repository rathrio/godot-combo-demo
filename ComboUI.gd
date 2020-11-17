extends Panel


onready var input_label: Label = $Input
onready var move_label: Label = $Move


func _on_Buffer_movement(move):
	move_label.text = move.id


func _on_Buffer_buffer_changed(buffer):
	if buffer.empty():
		return

	input_label.text = PoolStringArray(buffer).join(" ")

