extends Area2D

class_name Hitbox

export(NodePath) var sprite_path
var knockback = Vector2.ZERO

# Optional Move that was used to activate this hitbox
var move: Move
onready var sprite: Sprite = get_node(sprite_path)

func offset() -> Vector2:
	return sprite.offset
