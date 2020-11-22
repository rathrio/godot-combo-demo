extends KinematicBody2D

const ACCELERATION := 1000
const MAX_SPEED := 200
const FRICTION := 600

const MAX_OFFSET_DIFF := 30

enum State {
	MOVE,
	ATTACK,
	BLOCK,
	DASH,
	DASH_BACK
}

onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

onready var sprite: Sprite = $Sprite
onready var effect_sprite: Sprite = $EffectSprite
onready var hitbox: Position2D = $HitboxPivot
onready var hitbox_area: Hitbox = hitbox.get_node("Hitbox")
onready var hitlag: Timer = $Hitlag

export(float) var hitlag_time = 0.1

var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.RIGHT
var state = State.MOVE


func _ready():
	animation_tree.active = true
	hitbox.get_node("Hitbox/CollisionShape2D").disabled = true
	effect_sprite.visible = false


func _physics_process(delta):
	move()
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	# Reset faulty block
	if blocking() && not Input.is_action_pressed("block"):
		unblock()

	handle_movement(delta)


func get_input() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	return input_vector


func breaching() -> bool:
	return animation_state.get_current_node() == "Breach"


func moving() -> bool:
	return animation_state.get_current_node() == "Move"


func blocking() -> bool:
	return animation_state.get_current_node() == "Block"


func dashing() -> bool:
	return animation_state.get_current_node() == "Dash"


func handle_movement(delta: float):
	var input_vector = get_input()
	if input_vector != Vector2.ZERO && breaching():
		state = State.MOVE

	if not state == State.MOVE:
		return

	if input_vector != Vector2.ZERO:
		animation_state.travel("Move")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("Breach")

	if velocity.x < 0: # Facing left
		sprite.flip_h = true
		hitbox.rotation_degrees = 180
		direction = Vector2.LEFT
	elif velocity.x > 0: # Facing Right
		sprite.flip_h = false
		hitbox.rotation_degrees = 0
		direction = Vector2.RIGHT

	hitbox_area.knockback = direction


func move():
	velocity = move_and_slide(velocity)


func offsets_align(area: Area2D) -> bool:
	if not area.has_method("offset"):
		return true

	var offset_diff = abs(area.offset().y - sprite.offset.y)
	print(offset_diff)
	return offset_diff < MAX_OFFSET_DIFF


func _on_Hitbox_area_entered(area: Area2D):
	if not offsets_align(area):
		return

	if area.has_method("take_hit"):
		area.take_hit(hitbox_area)
		
	hitlag.start(hitlag_time)
	set_physics_process(false)
	animation_player.stop(false)


func _on_Hitlag_timeout():
	set_physics_process(true)
	if not animation_player.current_animation == "":
		animation_player.play()


func block():
	state = State.BLOCK
	animation_state.travel("Block")


func unblock():
	state = State.MOVE
	animation_state.travel("Breach")


func apply_velocity_factor(velocity_factor: Vector2):
	if velocity_factor != Vector2.ZERO:
		velocity = direction
		velocity.x *= velocity_factor.x
		velocity.y *= velocity_factor.y


func _on_CombatBuffer_action_just_pressed(action):
	match action:
		"block":
			if not blocking():
				block()


func _on_CombatBuffer_action_just_released(action):
	match action:
		"block":
			if blocking():
				unblock()


func _on_CombatBuffer_movement(move: Move):
	if dashing():
		return

	velocity = Vector2.ZERO
	execute_move(move)
	state = State.ATTACK


func _on_CombatBuffer_pause():
	if blocking():
		return
	# TODO some visual combo pause hint


func _on_MovementBuffer_movement(move: Move):
	if not blocking():
		return

	match move.id:
		"DashRight":
			if direction == Vector2.RIGHT:
				state = State.DASH
				animation_state.travel("Dash")
				apply_velocity_factor(move.velocity)
			else:
				state = State.DASH_BACK
				animation_state.travel("DashBack")
				apply_velocity_factor(move.velocity * -0.7)
		"DashLeft":
			if direction == Vector2.LEFT:
				state = State.DASH
				animation_state.travel("Dash")
				apply_velocity_factor(move.velocity)
			else:
				state = State.DASH_BACK
				animation_state.travel("DashBack")
				apply_velocity_factor(move.velocity * -0.7)


func _on_DashBuffer_movement(move: Move):
	if not dashing():
		return

	execute_move(move)

	# Consider keeping dash state to allow special dash combos
	state = State.ATTACK


# Execute move as is, i.e., the id can be used as animation and velocity does
# not need to be processed and can be applied directly.
#
# Note that this also sets the hitbox's move property.
func execute_move(move: Move):
	hitbox_area.move = move
	animation_state.travel(move.id)
	apply_velocity_factor(move.velocity)
