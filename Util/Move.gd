extends Resource

class_name Move

var id: String

# Will clear buffer, i.e., acts as a finisher in a combo.
var terminal: bool

# Velocity factors per axis. Applied to the direction of the KinematicBody to
# move it when executing this move.
var velocity: Vector2

var launch: bool

func _init(id: String, terminal = false, velocity = null, launch = false):
	self.id = id
	self.terminal = terminal
	if not velocity == null:
		self.velocity = velocity
	self.launch = launch
