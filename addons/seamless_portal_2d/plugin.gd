tool
extends EditorPlugin

const PORTAL_ICON := preload("assets/icons/portal_2d.svg")
const KINEMATIC_TRAVELER_ICON := preload("assets/icons/kinematic_traveler_2d.svg")
const RIGID_TRAVELER_ICON := preload("assets/icons/rigid_traveler_2d.svg")

const Portal2D := preload("portal_2d.gd")
const KinematicTraveler2D := preload("traveler/kinematic_traveler_2d.gd")
const RigidTraveler2D := preload("traveler/rigid_traveler_2d.gd")

func _enter_tree() -> void:
	add_custom_type("Portal2D", "StaticBody2D", Portal2D, PORTAL_ICON)
	add_custom_type("KinematicTraveler2D", "KinematicBody2D", KinematicTraveler2D, KINEMATIC_TRAVELER_ICON)
	add_custom_type("RigidTraveler2D", "RigidBody2D", RigidTraveler2D, RIGID_TRAVELER_ICON)


func _exit_tree() -> void:
	remove_custom_type("Portal2D")
	remove_custom_type("KinematicTraveler2D")
	remove_custom_type("RigidTraveler2D")
