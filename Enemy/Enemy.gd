extends KinematicBody2D

onready var hurtlag: Timer = $Hurtlag
onready var body: ColorRect = $Body

var knockback = Vector2.ZERO

export(float) var hurtlag_time = 0.1

const KNOCKBACK_STRENGTH = 100
const KNOCKBACK_FRICTION = 300

func _ready():
	body.color = Color.white

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)


func _on_Hurtbox_area_entered(area: Area2D):
	var knockback_vector = area.get("knockback")
	if not knockback_vector == null:
		knockback = knockback_vector * KNOCKBACK_STRENGTH

	body.color = Color.red
	set_physics_process(false)
	hurtlag.start(hurtlag_time)


func _on_Hurtlag_timeout():
	set_physics_process(true)
	body.color = Color.white
