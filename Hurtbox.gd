extends Area2D

class_name Hurtbox

signal take_hit(hitbox)

export(NodePath) var sprite_path

onready var sprite: Sprite = get_node(sprite_path)


func offset() -> Vector2:
	if sprite == null:
		print_debug("Warn: sprite is null")
		return Vector2.ZERO
	return sprite.offset


func take_hit(hitbox: Hitbox):
	emit_signal("take_hit", hitbox)
