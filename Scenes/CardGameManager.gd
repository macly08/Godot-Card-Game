extends Node

var game_timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_timer = $"../GameTimer"
	game_timer.one_shot = true
	game_timer.wait_time = 1.0



func _on_end_turn_button_pressed() -> void:
	opponent_turn()
	
func opponent_turn():
	$"../EndTurnButton".disabled = true
	$"../EndTurnButton".visible = false
	# wait 1 second
	game_timer.start()
	await game_timer.timeout
	
	
	
	
	$"../EndTurnButton".disabled = false
	$"../EndTurnButton".visible = true
