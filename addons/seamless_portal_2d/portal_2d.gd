tool
extends StaticBody2D
## docstring

#signals

#enums

const CORNER_BOUNDARY_HEIGHT = 2.0
const PASSAGE_BOUNDARY_WIDTH_SHRINK = .5
const TELEPORT_BUFFER = 10
const PASSAGE_NORMAL = Vector2.LEFT # Do not change, this could be made adjustable but at this moment many calculations assume the passage normal is left

var Portal2D = get_script() # I hate this
const KinematicTraveler = preload("traveler/kinematic_traveler_2d.gd")
const RigidTraveler = preload("traveler/rigid_traveler_2d.gd")
const VirtualKinematicBody2D = preload("virtual_body/virtual_kinematic_body_2d.gd")
const VirtualStaticBody2D = preload("virtual_body/virtual_static_body_2d.gd")
const VirtualRigidBody2D = preload("virtual_body/virtual_rigid_body_2d.gd")

export var enabled: bool = true

var linked_portal: StaticBody2D setget link

var _tracked_travelers: Array
var _traveler_system: Array
var _cullred_bodies: Array
var _virtual_by_real_body: Dictionary

onready var _virtual_collision_area = Area2D.new()
onready var _collision_cull_area = Area2D.new()
onready var _passage_area: Area2D = Area2D.new()
onready var _passage_collision_shape: CollisionShape2D = _get_passage_collision_shape()
onready var _top_boundary: StaticBody2D = StaticBody2D.new()
onready var _bottom_boundary: StaticBody2D = StaticBody2D.new()


func _ready() -> void:
	if Engine.editor_hint: return

	_collision_cull_area.connect("body_entered", self, "_on_CollisionCullArea_body_entered")
	_collision_cull_area.connect("body_exited", self, "_on_CollisionCullArea_body_exited")
	_passage_area.connect("body_entered", self, "_on_PassageArea_body_entered")
	_passage_area.connect("body_exited", self, "_on_PassageArea_body_exited")
	_virtual_collision_area.connect("body_entered", self, "_on_VirtualCollisionArea_body_entered")
	_virtual_collision_area.connect("body_exited", self, "_on_VirtualCollisionArea_body_exited")

	var collision_shape: CollisionShape2D

	for node in [_passage_area, _top_boundary, _bottom_boundary]:
		collision_shape = CollisionShape2D.new()
		collision_shape.shape = RectangleShape2D.new()
		node.add_child(collision_shape)
		add_child(node)

	collision_shape = CollisionShape2D.new()
	collision_shape.shape = ConvexPolygonShape2D.new()
	_collision_cull_area.add_child(collision_shape)
	_collision_cull_area.set_collision_layer_bit(19, true)
	add_child(_collision_cull_area)

	collision_shape = CollisionShape2D.new()
	collision_shape.shape = ConvexPolygonShape2D.new()
	_virtual_collision_area.add_child(collision_shape)
	add_child(_virtual_collision_area)

	_adjust_collision_shapes()

func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		update_configuration_warning()
		return

	if enabled:
		for node in _tracked_travelers:
			var traveler := node as PhysicsBody2D
			var teleport_to_transform := _calc_teleport(traveler)
			var facing_direction := PASSAGE_NORMAL.rotated(rotation)
			var direction_to_traveler := global_position.direction_to(traveler.global_position)
			var has_traveler_crossed_passage := facing_direction.dot(direction_to_traveler) < 0
			traveler._traversing_portal(self, linked_portal, _calc_teleport(traveler))

			if has_traveler_crossed_passage:
				traveler.teleport(teleport_to_transform, linked_portal.get_passage_normal())
				traveler._traversing_portal(linked_portal, self, linked_portal._calc_teleport(traveler))
				_traveler_exited_portal(traveler, true)
				linked_portal._traveler_entered_portal(traveler, true)

				if _virtual_by_real_body.has(traveler):
					_virtual_by_real_body[traveler].get_parent().remove_child(_virtual_by_real_body[traveler])

func _get_configuration_warning() -> String:
	var collision_shape_count := 0

	for node in get_children():
		if node is CollisionShape2D or node is CollisionPolygon2D:
			collision_shape_count += 1

	if collision_shape_count > 1:
		return "Portal is intended to work with 1 collision shape only"

	var passage_collision_shape := _get_passage_collision_shape()
	if passage_collision_shape != null:
		var shape: Shape2D = passage_collision_shape.shape
		if not shape is RectangleShape2D:
			return "Portal CollisionShape2D is expected to use a RectangleShaped2D shape"
	else:
		return "Portal is expected to have 1 CollisionShape2D that uses a RectangleShape2D shape"

	return ""

func _to_string() -> String:
	return "[%s:%s]" % [get_class(), get_instance_id()];

func link(portal: StaticBody2D):
	if portal is Portal2D:
		if portal != self:
			linked_portal = portal;
			linked_portal._traveler_system = _traveler_system
			if portal != null and portal.linked_portal != self:
				portal.linked_portal = self;
		else:
			push_error("Can not link portal to self");
	else:
		push_error("Argument must be Portal2D. You'd have gotten a compile time error if static typing was better")

func can_use_portal() -> bool:
	return enabled and linked_portal != null

func has_traveler(traveler: Node) -> bool:
	return _is_traveler(traveler) and _tracked_travelers.has(traveler)

func is_flipped() -> bool:
	var facing_direction := PASSAGE_NORMAL.rotated(rotation)
	return PASSAGE_NORMAL.dot(facing_direction) < 0

func get_teleport_rotation() -> float:
	var facing_direction := PASSAGE_NORMAL.rotated(rotation)
	var is_flipped = PASSAGE_NORMAL.dot(facing_direction) < 0
	var rot := fmod(rotation_degrees, 360)

	return deg2rad(rot - 180 if is_flipped else rot)

func get_passage_extents() -> Vector2:
	return _passage_collision_shape.shape.extents if _passage_collision_shape != null else Vector2.ZERO

func get_passage_normal() -> Vector2:
	return PASSAGE_NORMAL.rotated(rotation)

func get_class() -> String:
	return "Portal2D"

func _traveler_entered_portal(traveler: PhysicsBody2D, is_teleported: bool = false) -> void:
	if can_use_portal() and _is_traveler(traveler) and not _is_in_either_portal(traveler):
		for body in _cullred_bodies:
			traveler.add_collision_exception_with(body)

		if not is_teleported and not _traveler_system.has(traveler):
			_traveler_entered_portal_system(traveler)

		_tracked_travelers.append(traveler)
		traveler._portal_entered(self)

func _traveler_exited_portal(traveler: PhysicsBody2D, is_teleported: bool = false) -> void:
	if _is_traveler(traveler) and _tracked_travelers.has(traveler):
		for body in _cullred_bodies:
			if body != linked_portal and not linked_portal._cullred_bodies.has(body):
				traveler.remove_collision_exception_with(body)

		if not linked_portal._tracked_travelers.has(traveler):
			for body in _cullred_bodies:
				traveler.remove_collision_exception_with(body)

		if not is_teleported and _traveler_system.has(traveler):
			_traveler_exited_portal_system(traveler)

		_tracked_travelers.erase(traveler)
		traveler._portal_exited(self)

func _traveler_entered_portal_system(traveler: PhysicsBody2D) -> void:
	_traveler_system.append(traveler)
	traveler.add_collision_exception_with(self)
	traveler.add_collision_exception_with(linked_portal)
	traveler._portal_system_entered()

func _traveler_exited_portal_system(traveler: PhysicsBody2D) -> void:
	_traveler_system.erase(traveler)
	traveler.remove_collision_exception_with(self)
	traveler.remove_collision_exception_with(linked_portal)
	traveler._portal_system_exited()

func _calc_teleport(body: PhysicsBody2D) -> Transform2D:
	var flip_transform := Transform2D.IDENTITY if linked_portal.is_flipped() != is_flipped() else Transform2D.FLIP_Y
	var linked_portal_passage_normal = linked_portal.get_passage_normal()
	var linked_portal_transform := Transform2D(linked_portal_passage_normal.angle(), linked_portal.global_position)
	var teleport_transform: Transform2D = linked_portal_transform * flip_transform * global_transform.inverse() * body.global_transform
	teleport_transform.origin += linked_portal_passage_normal * TELEPORT_BUFFER
	return teleport_transform

func _is_in_either_portal(traveler: Node) -> bool:
	return _tracked_travelers.has(traveler) or linked_portal._tracked_travelers.has(traveler)

func _is_traveler(node: Node) -> bool:
	return node is KinematicTraveler or node is RigidTraveler

func _is_virtual_body(node: PhysicsBody2D) -> bool:
	return node is VirtualKinematicBody2D or node is VirtualRigidBody2D or node is VirtualStaticBody2D

func _get_passage_collision_shape() -> CollisionShape2D:
	for node in get_children():
		if node is CollisionShape2D:
			return node
	return null

func _adjust_collision_shapes() -> void:
	if is_inside_tree():
		var border_extents = get_passage_extents()
		var passage_height = border_extents.y - CORNER_BOUNDARY_HEIGHT * 2 - 2
		_passage_area.get_child(0).shape.extents = Vector2(border_extents.x, passage_height - 2)
		_passage_area.position = border_extents * PASSAGE_NORMAL * 2
		_top_boundary.get_child(0).shape.extents = Vector2(border_extents.x, CORNER_BOUNDARY_HEIGHT)
		_top_boundary.position = Vector2(0, border_extents.y - CORNER_BOUNDARY_HEIGHT)
		_bottom_boundary.get_child(0).shape.extents = Vector2(border_extents.x, CORNER_BOUNDARY_HEIGHT)
		_bottom_boundary.position = Vector2(0, -border_extents.y + CORNER_BOUNDARY_HEIGHT)
		_virtual_collision_area.get_child(0).shape.set_point_cloud([
			_top_boundary.position + Vector2(-border_extents.x, 0),
			_bottom_boundary.position + Vector2(-border_extents.x, 0),
			-_top_boundary.position.rotated(deg2rad(-45)) * 10,
			-_bottom_boundary.position.rotated(deg2rad(45)) * 10,
		])
		_collision_cull_area.get_child(0).shape.set_point_cloud([
			_top_boundary.position + Vector2(border_extents.x, 0),
			_bottom_boundary.position + Vector2(border_extents.x, 0),
			-_top_boundary.position.rotated(deg2rad(45)) * 10,
			-_bottom_boundary.position.rotated(deg2rad(-45)) * 10,
			#-_top_boundary.position.rotated(deg2rad(5)) * 30,
			#-_bottom_boundary.position.rotated(deg2rad(-5)) * 30,
		])

func _on_PassageArea_body_entered(body: Node) -> void:
	_traveler_entered_portal(body)

func _on_PassageArea_body_exited(body: Node) -> void:
	_traveler_exited_portal(body)

func _on_CollisionCullArea_body_entered(body: Node) -> void:
	if not _tracked_travelers.has(body) and not _cullred_bodies.has(body) and not body in [_top_boundary, _bottom_boundary]:
		_cullred_bodies.append(body)

		for traveler in _tracked_travelers:
			traveler.add_collision_exception_with(body)

func _on_CollisionCullArea_body_exited(body: Node) -> void:
	if _cullred_bodies.has(body):
		_cullred_bodies.erase(body)

		for traveler in _tracked_travelers:
			traveler.remove_collision_exception_with(body)

func _on_VirtualCollisionArea_body_entered(body: Node) -> void:
	var portal_exclusion := [self, _top_boundary, _bottom_boundary, linked_portal, linked_portal._top_boundary, linked_portal._bottom_boundary]
	if body is PhysicsBody2D and not _is_virtual_body(body) and not body in portal_exclusion:
		if body is StaticBody2D:
			var virtual_body := VirtualStaticBody2D.new(body)
			linked_portal.add_child(virtual_body)
			virtual_body.global_transform = _calc_teleport(body)
			_virtual_by_real_body[body] = virtual_body
		# Disabled until better solution can be found

		elif body is KinematicBody2D:
			var virtual_body := VirtualKinematicBody2D.new(body)
			linked_portal.add_child(virtual_body)
			virtual_body.global_transform = _calc_teleport(body)
			_virtual_by_real_body[body] = virtual_body
			pass

		elif body is RigidBody2D:
			var virtual_body := VirtualRigidBody2D.new(body)
			linked_portal.add_child(virtual_body)
			virtual_body.global_transform = _calc_teleport(body)
			_virtual_by_real_body[body] = virtual_body
			pass


func _on_VirtualCollisionArea_body_exited(body: Node) -> void:
	if body is PhysicsBody2D and not _is_virtual_body(body) and _virtual_by_real_body.has(body):
		var virtual_body := _virtual_by_real_body[body] as PhysicsBody2D
		virtual_body.queue_free()
		_virtual_by_real_body.erase(body)
