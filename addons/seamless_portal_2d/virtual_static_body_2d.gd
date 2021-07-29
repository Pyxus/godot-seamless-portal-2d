extends StaticBody2D
## docstring

#signals

#enums

#constants

#preloaded scripts

#exported variables

var real_body: StaticBody2D

#private variables

#onready variables


#optional built-in virtual _init method

#built-in virtual _ready method

#remaining built-in virtual methods

func initialize(body: StaticBody2D, starting_transform: Transform2D) -> void:
	real_body = body
	global_transform = starting_transform

	collision_layer = 0
	collision_mask = 1 << 19

	for node in real_body.get_children():
		if node is CollisionShape2D:
			var collision_shape := CollisionShape2D.new()
			collision_shape.shape = node.shape.duplicate()
			collision_shape.position = node.position
			call_deferred("add_child", collision_shape)

#private methods

#signal methods
