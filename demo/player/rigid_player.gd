extends "res://addons/seamless_portal_2d/traveler/rigid_traveler_2d.gd"
## docstring

#signals

#enums

#constants

#preloaded scripts

#exported variables

var speed := 300.0;

#private variables

onready var _sprite: Sprite = get_node("Sprite")


#optional built-in virtual _init method

#built-in virtual _ready method

func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if Input.is_action_pressed("ui_right"):
		state.linear_velocity.x = speed;
	elif Input.is_action_pressed("ui_left"):
		state.linear_velocity.x = -speed;
	else:
		state.linear_velocity.x = 0.0;

	if Input.is_action_pressed("ui_down"):
		state.linear_velocity.y = speed;
	elif Input.is_action_pressed("ui_up"):
		state.linear_velocity.y = -speed;
	else:
		state.linear_velocity.y = 0.0;
	pass

func _get_clone_texture() -> Texture:
	return _sprite.texture

func _get_clip_material() -> ShaderMaterial:
	return _sprite.material as ShaderMaterial

#public methods

#private methods

#signal methods
