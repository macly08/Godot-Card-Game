extends Node2D

signal hovered
signal hovered_off
signal card_clicked

var hand_position
var in_card_slot
var primed = false

#Tuple of [value, suit].
var card_values

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Children must have the card manager as the parent!
	get_parent().connect_card_signals(self)


func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)


func _on_area_2d_mouse_exited() -> void:
	emit_signal("hovered_off", self)
		
