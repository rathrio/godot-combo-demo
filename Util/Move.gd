extends Resource

class_name Move

var id: String
var terminal: bool

# Velocity factors per axis
var velocity: Vector2

func _init(id: String, terminal = false, velocity = Vector2.ZERO):
	self.id = id
	self.terminal = terminal
	self.velocity = velocity
