extends Panel


onready var input_label: Label = $Input
onready var move_label: Label = $Move


func _on_InputBuffer_input_changed(input):
	input_label.text = PoolStringArray(input).join(" ")


func _on_InputBuffer_movement(move: Move):
	move_label.text = move.id
