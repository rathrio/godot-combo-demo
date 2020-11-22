extends KinematicBody2D

export(float) var hurtlag_time = 0.1

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var hurtlag = $Hurtlag
onready var sprite: Sprite = $Sprite
onready var tween: Tween = $Tween

var knockback := Vector2.ZERO

const KNOCKBACK_STRENGTH := 100
const KNOCKBACK_FRICTION := 300
const LAUNCH_APEX := Vector2(0, -40)
const LAUNCH_DURATION := 0.5

enum State {
	MOVE,
	ATTACK,
	BLOCK,
	DASH,
	DASH_BACK,
	LAUNCHED
}

var state = State.MOVE
var direction: Vector2 = Vector2.RIGHT


func _ready():
	animation_tree.active = true
	animation_state.travel("Idle")
	hurtlag.autostart = false
	hurtlag.one_shot = true


func at_launch_apex() -> bool:
	return $Sprite.offset == LAUNCH_APEX

# When launched by launch attack
func launch():
	state = State.LAUNCHED
	animation_state.travel("Hurt2")
	tween.interpolate_property(
		sprite,
		"offset",
		sprite.offset,
		LAUNCH_APEX,
		LAUNCH_DURATION,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT
	)
	tween.start()


func fall():
	animation_state.travel("Fall")
	tween.interpolate_property(
		sprite,
		"offset",
		sprite.offset,
		Vector2.ZERO,
		LAUNCH_DURATION,
		Tween.TRANS_CIRC,
		Tween.EASE_IN
	)
	tween.start()

func land():
	state = State.MOVE
	animation_state.travel("Land")


func grounded() -> bool:
	return sprite.offset == Vector2.ZERO


func launched() -> bool:
	return state == State.LAUNCHED


func _physics_process(delta):
	reorient_sprite()

	var knockback_friction = KNOCKBACK_FRICTION
	if launched():
		# Less "friction" in air
		knockback_friction *= 0.7

		if grounded():
			land()

	knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)
	knockback = move_and_slide(knockback)

	if at_launch_apex():
		fall()


func reorient_sprite():
	sprite.flip_h = direction != Vector2.RIGHT


func _on_Hurtbox_area_entered(area):
	var knockback_vector = area.get("knockback")
	if not knockback_vector == null:
		knockback = knockback_vector * KNOCKBACK_STRENGTH
		# Face player when getting attacked
		direction = knockback_vector.normalized() * -1
		reorient_sprite()

	var move = area.get("move")
	if not move == null and move.launch:
		launch()
	else:
		if launched():
			animation_state.travel("Hurt3")
		else:
			animation_state.travel("Hurt1")

	hurtlag.start(hurtlag_time)
	set_physics_process(false)
	animation_player.stop(false)
	tween.stop(sprite, "offset")


func _on_Hurtlag_timeout():
	set_physics_process(true)
	if not animation_player.current_animation == "":
		animation_player.play()
	tween.resume(sprite, "offset")
