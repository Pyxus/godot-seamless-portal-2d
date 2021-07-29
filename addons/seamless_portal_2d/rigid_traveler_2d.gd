extends RigidBody2D
## docstring

#signals

#enums

const CLIP_SHADER = preload("res://addons/seamless_portal_2d/clip.shader")

#preloaded scripts

#exported variables

#public variables

var _is_teleported: bool = false
var _teleport_transform: Transform2D

onready var _teleport_clone: Sprite = Sprite.new()


#optional built-in virtual _init method

func _ready() -> void:
	var material = ShaderMaterial.new()
	material.shader = CLIP_SHADER
	_teleport_clone.material = material
	set_collision_layer_bit(19, true)

func _to_string() -> String:
	return "[%s:%s]" % [get_class(), get_instance_id()];

func _get_clip_material() -> ShaderMaterial:
	return null

func _traversing_portal(from_portal: Node2D, to_portal: Node2D, teleport_transform: Transform2D) -> void:
	_teleport_clone.global_transform = teleport_transform
	var material = _get_clip_material()
	if material != null:
		var offset_from_portal := global_position - from_portal.global_position
		material.set_shader_param("clip_offset", -to_portal.get_border_extents().x)
		material.set_shader_param("clip_center", from_portal.global_position)
		material.set_shader_param("clip_normal", -from_portal.get_passage_normal())
		material.set_shader_param("global_transform", global_transform)

		_teleport_clone.material.set_shader_param("clip_offset", -to_portal.get_border_extents().x)
		_teleport_clone.material.set_shader_param("clip_center", to_portal.global_position)
		_teleport_clone.material.set_shader_param("clip_normal", -to_portal.get_passage_normal())
		_teleport_clone.material.set_shader_param("global_transform", _teleport_clone.global_transform)

func _portal_entered(portal: Node2D) -> void:
	pass

func _portal_exited(portal: Node2D) -> void:
	pass

func _portal_system_entered() -> void:
	_teleport_clone.texture = _get_clone_texture()
	_teleport_clone.set_as_toplevel(true)
	add_child(_teleport_clone)

func _portal_system_exited() -> void:
	remove_child(_teleport_clone)

func _get_clone_texture() -> Texture:
	return null

func teleport(to: Transform2D, direction: Vector2) -> void:
	global_transform = to
	linear_velocity = direction * linear_velocity.length()
	applied_force = direction * applied_force.length()
	angular_velocity *= sign(direction.angle()) # Brain is failing me now, not sure if this is how you'd handle the convertion

func get_clone_texture() -> Texture:
	return _get_clone_texture()

func get_class() -> String:
	return "RigidTraveler2D";

#private methods

#signal methods
