extends KinematicBody2D
## docstring

#signals

#enums

#constants

#preloaded scripts

#exported variables

var real_body: PhysicsBody2D

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

func _physics_process(delta: float) -> void:
	if real_body != null:
		var real_body_state := Physics2DServer.body_get_direct_state(real_body.get_rid())
		move_and_slide(real_body_state.linear_velocity * 1.1)

func initialize(body: PhysicsBody2D, starting_transform: Transform2D) -> void:
	real_body = body
	global_transform = starting_transform

	collision_layer = 0
	collision_mask = 1 << 19
	layers = 1 << 19

	for node in real_body.get_children():
		if node is CollisionShape2D:
			var collision_shape := CollisionShape2D.new()
			collision_shape.shape = node.shape.duplicate()
			collision_shape.position = node.position
			call_deferred("add_child", collision_shape)

#private methods

#signal methods
