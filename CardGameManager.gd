extends Node
class_name CardGameManager

var start_draw_size = 5
var more_draws_allowed = false
var game_timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_timer = $"../GameTimer"
	game_timer.one_shot = true
	game_timer.wait_time = 1.0

func init_gamerules():
	pass

func draw_allowed() -> bool:
	return more_draws_allowed

func _on_end_turn_button_pressed() -> void:
	opponent_turn()

func player_turn():
	pass
	
func opponent_turn():
	pass

func disable_button(button: Button) -> void:
	button.disabled = true
	button.visible = false
	
func enable_button(button: Button) -> void:
	button.disabled = false
	button.visible = true
	
func end_game():
	pass
