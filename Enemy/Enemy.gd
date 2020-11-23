extends KinematicBody2D

onready var hurtlag: Timer = $Hurtlag
onready var body: ColorRect = $Body
onready var health: Health = $Health

var knockback = Vector2.ZERO

export(float) var hurtlag_time = 0.1

const KNOCKBACK_STRENGTH = 100
const KNOCKBACK_FRICTION = 300

func _ready():
	body.color = Color.white


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)


func _on_Hurtlag_timeout():
	set_physics_process(true)
	body.color = Color.white


func _on_Health_depleted():
	queue_free()


func _on_Hurtbox_take_hit(hitbox: Hitbox):
	var knockback_vector = hitbox.knockback
	knockback = knockback_vector * KNOCKBACK_STRENGTH

	body.color = Color.red
	set_physics_process(false)
	hurtlag.start(hurtlag_time)
	health.decrease(5)
