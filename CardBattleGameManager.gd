extends CardGameManager

var player_hp = 50
var enemy_hp = 50

func init_gamerules():
	start_draw_size = 12
	print(start_draw_size)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_draw_size = 12
	start_game()
	
	
func start_game():
	more_draws_allowed = true
	for i in range (0, start_draw_size):
		$"../Deck".draw_card(true, $"../PlayerHand")
		$"../Deck".draw_card(false, $"../EnemyHand")
	more_draws_allowed = false
	player_turn()
	
func player_turn():
	var card = $"../PlayerHand".pick_random_card()
	var damage = $"../PlayerHand".play_card(card)
	enemy_hp -= damage
	get_node("EnemyHP").text = "Enemy HP: " + str(enemy_hp)
	await get_tree().create_timer(2).timeout
	if enemy_hp < 0:
		end_game()
	else:
		opponent_turn()
	
func opponent_turn():
	var enemy_card = $"../EnemyHand".pick_random_card()
	var damage = $"../EnemyHand".play_card(enemy_card)
	player_hp -= damage
	get_node("PlayerHP").text = "Your HP: " + str(player_hp)
	await get_tree().create_timer(2).timeout
	if player_hp < 0:
		end_game()
	else:
		player_turn()
	
func end_game():
	get_node("GameOverLabel").modulate.a = 1
	get_tree().paused = true
