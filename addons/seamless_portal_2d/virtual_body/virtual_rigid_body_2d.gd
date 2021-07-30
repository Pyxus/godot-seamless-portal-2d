extends RigidBody2D
## docstring

#signals

#enums

#constants

#preloaded scripts

#exported variables

var real_body: RigidBody2D

#private variables

#onready variables


func _init(body: RigidBody2D) -> void:
	real_body = body
	collision_layer = 0
	collision_mask = 1 << 19

	for node in real_body.get_children():
		if node is CollisionShape2D:
			var collision_shape := CollisionShape2D.new()
			collision_shape.position = node.position
			collision_shape.set_deferred("shape", node.shape)
			add_child(collision_shape)

#built-in virtual _ready method

func _physics_process(delta: float) -> void:
	if real_body != null:
		#var linear_velocity: Vector2 = Physics2DServer.body_get_state(real_body.get_rid(), Physics2DServer.BODY_STATE_LINEAR_VELOCITY)
		#var angular_velocity: float = Physics2DServer.body_get_state(real_body.get_rid(), Physics2DServer.BODY_STATE_ANGULAR_VELOCITY)
		#linear_velocity = linear_velocity
		#angular_velocity = angular_velocity
		Physics2DServer.body_set_state(get_rid(), Physics2DServer.BODY_STATE_LINEAR_VELOCITY, real_body.linear_velocity)
		Physics2DServer.body_set_state(get_rid(), Physics2DServer.BODY_STATE_ANGULAR_VELOCITY, real_body.angular_velocity)

#public methods

#private methods

#signal methods
