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


func _init(body: StaticBody2D) -> void:
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
		constant_linear_velocity = real_body.constant_linear_velocity
		constant_angular_velocity = real_body.constant_angular_velocity
		physics_material_override = real_body.physics_material_override

#public method

#private methods

#signal methods
