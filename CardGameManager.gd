extends Node
class_name CardGameManager

var start_draw_size = 5
var more_draws_allowed = false
var game_timer
var game_status_text
var can_play_card

func init_timer(t: float):
	pass

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

func end_game():
	pass
	
func reset_board():
	pass

func disable_button(button: Button) -> void:
	button.disabled = true
	button.visible = false
	
func enable_button(button: Button) -> void:
	button.disabled = false
	button.visible = true
	
func get_card_clicked(card):
	pass
	
