extends KinematicBody2D
## docstring

#signals

#enums

const CLIP_SHADER = preload("res://addons/seamless_portal_2d/clip.shader")

#preloaded scripts

#exported variables

#public variables

#private variables

onready var _teleport_clone: Sprite = Sprite.new()


#optional built-in virtual _init method

func _ready() -> void:
	var material = ShaderMaterial.new()
	material.shader = CLIP_SHADER
	_teleport_clone.material = material

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
	set_collision_layer_bit(19, true)

func _portal_system_exited() -> void:
	remove_child(_teleport_clone)
	set_collision_layer_bit(19, false)

func _get_clone_texture() -> Texture:
	return null

"""
func move_and_slide(linear_velocity: Vector2, up_direction: Vector2 = Vector2( 0, 0 ), stop_on_slope: bool = false, max_slides: int = 4, floor_max_angle: float = 0.785398, infinite_inertia: bool = true) -> Vector2:
	if _teleport_clone.is_inside_tree():
		var delta := get_physics_process_delta_time() if Engine.is_in_physics_frame() else get_process_delta_time()
		var result := Physics2DTestMotionResult.new()
		var from := _teleport_clone.get_global_transform()
		var motion := linear_velocity * delta
		var has_collision := Physics2DServer.body_test_motion(get_rid(), from, motion, infinite_inertia, get_safe_margin(), result)

		if has_collision:

			var velocity = result.motion_remainder.slide(result.collision_normal)
			return .move_and_slide(velocity, up_direction, stop_on_slope, max_slides, floor_max_angle, infinite_inertia)
	return .move_and_slide(linear_velocity, up_direction, stop_on_slope, max_slides, floor_max_angle, infinite_inertia);
"""

func teleport(to: Transform2D, direction: Vector2) -> void:
	transform = to

func get_clone_texture() -> Texture:
	return _get_clone_texture()

func get_class() -> String:
	return "KinematicTraveler2D";

#private methods

#signal methods
