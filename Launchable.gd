extends Node

# Launch animation for Sprites
class_name Launchable

signal launch
signal fall

export(NodePath) var sprite_path
export(Vector2) var launch_apex = Vector2(0, -40)
export(float) var launch_duration = 0.4
export(float) var fall_duration = 0.3

onready var sprite: Sprite = get_node(sprite_path)
onready var tween: Tween = $Tween

func _physics_process(delta):
	if at_apex():
		fall()

func at_apex() -> bool:
	return sprite.offset == launch_apex

func launch():
	emit_signal("launch")
	tween.interpolate_property(
		sprite,
		"offset",
		sprite.offset,
		launch_apex,
		launch_duration,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT
	)
	tween.start()


func fall():
	emit_signal("fall")
	tween.interpolate_property(
		sprite,
		"offset",
		sprite.offset,
		Vector2.ZERO,
		fall_duration,
		Tween.TRANS_CIRC,
		Tween.EASE_IN
	)
	tween.start()


func pause():
	tween.stop(sprite, "offset")
	
	
func resume():
	tween.resume(sprite, "offset")
