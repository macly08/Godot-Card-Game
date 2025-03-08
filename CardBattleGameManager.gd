extends CardGameManager

var hand_y_pos = 120
var player_hp = 50
var enemy_hp = 50
var round_num = 1

func init_gamerules():
	start_draw_size = 12
	print(start_draw_size)
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_draw_size = 10
	start_game()
	
	
func start_game():
	more_draws_allowed = true
	for i in range (0, start_draw_size):
		$"../Deck".draw_card(true, $"../PlayerHand")
		$"../Deck".draw_card(false, $"../EnemyHand")
	more_draws_allowed = false
	player_turn()
	
func player_turn():
	var player_hand = $"../PlayerHand"
	var card = player_hand.pick_random_card()
	var damage = handle_card_suit_effects(card, true, player_hand.player_hand)
	enemy_hp -= damage
	player_hand.remove_card_from_hand(player_hand.player_hand[card])
	get_node("EnemyHP").text = "Enemy HP: " + str(enemy_hp)
	await get_tree().create_timer(2).timeout
	if enemy_hp < 0:
		end_game()
	else:
		opponent_turn()
	
func opponent_turn():
	var enemy_hand = $"../EnemyHand"
	var enemy_card = enemy_hand.pick_random_card()
	var damage = handle_card_suit_effects(enemy_card, false, enemy_hand.player_hand)
	player_hp -= damage
	enemy_hand.remove_card_from_hand(enemy_hand.player_hand[enemy_card])
	get_node("PlayerHP").text = "Your HP: " + str(player_hp)
	await get_tree().create_timer(2).timeout
	if player_hp < 0:
		end_game()
	else:
		player_turn()
		
func handle_card_suit_effects(card, is_player, hand) -> int:
	var suit = hand[card].card_values[1]
	var card_val = hand[card].card_values[0]
	if suit == "Hearts":
		print ("Hearts. Healing ", is_player, " for ", card_val)
		if is_player:
			player_hp += card_val
		else:
			enemy_hp += card_val
		return card_val
	elif suit == "Spades":
		print("Spades. Dealing ", card_val, " * 2 dmg")
		return card_val * 2
	elif suit == "Clubs":
		print("Clubs. Dealing ", card_val, " + 4 dmg")
		return card_val + 4
	else: #diamonds
		print("Diamonds. Healing ", card_val + 5, " hp")
		if is_player:
			player_hp += 5
		else:
			enemy_hp += 5
		return card_val
		
func end_game():
	get_node("GameOverLabel").modulate.a = 1
	get_tree().paused = true
