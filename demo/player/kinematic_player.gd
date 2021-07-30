extends "res://addons/seamless_portal_2d/traveler/kinematic_traveler_2d.gd"
## docstring

#signals

#enums

#constants

#preloaded scripts

#exported variables

var velocity : Vector2;
var speed := 300.0;

#private variables

onready var _sprite: Sprite = get_node("Sprite")


#optional built-in virtual _init method

#built-in virtual _ready method

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed;
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed;
	else:
		velocity.x = 0.0;

	if Input.is_action_pressed("ui_down"):
		velocity.y = speed;
	elif Input.is_action_pressed("ui_up"):
		velocity.y = -speed;
	else:
		velocity.y = 0.0;

	velocity = move_and_slide(velocity)

func _get_clone_texture() -> Texture:
	return _sprite.texture

func _get_clip_material() -> ShaderMaterial:
	return _sprite.material as ShaderMaterial

#public methods

#private methods

#signal methods
