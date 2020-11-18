extends Node

class_name Health

signal depleted
signal changed(new_health)

export(int, 0, 1000) var max_health = 100
onready var health: int = max_health


func decrease(value):
	if health == 0:
		return

	health -= value
	if health <= 0:
		health = 0
		emit_signal("depleted")
		
	emit_signal("changed", health)
