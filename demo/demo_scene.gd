extends Node
## docstring

#signals

#enums

#constants

#preloaded scripts

#exported variables

#public variables

#private variables

#onready variables


#optional built-in virtual _init method

func _ready() -> void:
	get_node("Portal2D").link(get_node("Portal2D2"))
	pass

func _physics_process(_delta: float) -> void:
	#get_node("KinematicBody2D").move_and_slide(Vector2.LEFT * 10)
	pass

#public methods

#private methods

#signal methods
