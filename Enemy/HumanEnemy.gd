extends KinematicBody2D

export(float) var hurtlag_time = 0.1

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var hurtlag = $Hurtlag
onready var sprite: Sprite = $Sprite

var knockback = Vector2.ZERO

const KNOCKBACK_STRENGTH = 100
const KNOCKBACK_FRICTION = 300
const GRAVITY = 100

func _ready():
	animation_tree.active = true
	animation_state.travel("Idle")
	hurtlag.autostart = false
	hurtlag.one_shot = true


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)
	apply_gravity(delta)


func apply_gravity(delta: float):
	if sprite.offset == Vector2.ZERO:
		return

	sprite.offset = sprite.offset.move_toward(Vector2.ZERO, GRAVITY * delta)

func _on_Hurtbox_area_entered(area):
	var knockback_vector = area.get("knockback")
	if not knockback_vector == null:
		knockback = knockback_vector * KNOCKBACK_STRENGTH

	animation_state.travel("Hurt1")
	hurtlag.start(hurtlag_time)
	set_physics_process(false)
	animation_player.stop(false)


func _on_Hurtlag_timeout():
	set_physics_process(true)
	if not animation_player.current_animation == "":
		animation_player.play()
