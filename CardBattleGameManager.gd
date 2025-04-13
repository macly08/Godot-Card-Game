extends CardGameManager

var hand_y_pos = 120
var player_hp = 50
var player_max_hp = 50
var enemy_hp = 50
var enemy_max_hp = 50
var round_num = 1
var cards_per_round = 4
var card_counter = 0
var player_attack
var opponent_attack
#Shield = extra hp basically
var player_shield = 0
var opponent_shield = 0
#Armor = damage reduction on next turn
var player_armor = 0
var opponent_armor = 0
#Clubs bonus damage
var player_clubs_bonus = 0
var opponent_clubs_bonus = 0

signal card_clicked

func init_gamerules():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()
		
func start_game():
	more_draws_allowed = true
	draw_cards_to_hands(cards_per_round)
	more_draws_allowed = false
	round_num = 1
	var whose_turn = coin_flip()
	if whose_turn == 1:
		print("player starts attack")
		player_attack = true
		opponent_attack = false
		var card_text = get_node("PlayCardText")
		card_text.modulate.a = 1
		card_text.text = "[center]Play a card for Attack![/center]"
		#player_attack_turn()
	else: 
		print("opponent starts attack")
		opponent_attack = true
		player_attack = false
		var card_text = get_node("PlayCardText")
		card_text.modulate.a = 1
		card_text.text = "[center]Play a card for Defense![/center]"
		#player_attack_turn()
	can_play_card = true
	
func coin_flip():
	return floor(randf_range(0,2))
	
func draw_cards_to_hands(num_cards):
	print("Drawing", num_cards, "to both players' hands")
	for i in range (0, num_cards):
		$"../Deck".draw_card(true, $"../PlayerHand")
		$"../Deck".draw_card(false, $"../EnemyHand")
		
func get_card_clicked(card):
	if can_play_card:
		print("card clicked, and is valid to play.")
		commence_turn(card)
	else:
		print("card clicked, invalid time!")

func commence_turn(players_card):
	can_play_card = false
	print("turn commencing.")
	var opponents_hand = $"../EnemyHand"
	var players_hand = $"../PlayerHand"
	var opponents_card = opponents_hand.pick_random_card()
	var opponents_card_suit = opponents_card.card_values[1]
	var opponents_card_val = opponents_card.card_values[0]
	print("Your card:", players_card, "Are you attacking?", player_attack)
	print("Opponents card:", opponents_card, "Is opponent attacking?", opponent_attack)
	
	var card_val = players_card.card_values[0]
	var suit = players_card.card_values[1]
	if player_attack:
		var attacking_card = players_card
		var defending_card = opponents_card
		handle_card_suit_effects(attacking_card, defending_card, true)
		players_hand.remove_card_from_hand(attacking_card)
		opponents_hand.remove_card_from_hand(defending_card)
		player_attack = false
		opponent_attack = true
	else:
		var attacking_card = opponents_card
		var defending_card = players_card
		handle_card_suit_effects(attacking_card, defending_card, false)
		players_hand.remove_card_from_hand(defending_card)
		opponents_hand.remove_card_from_hand(attacking_card)
		player_attack = true
		opponent_attack = false
	#Out of cards: draw more and increment round number.
	print("hand size:", players_hand.player_hand.size(), "round number:", round_num)
	if players_hand.player_hand.size() == 0:
		if round_num == 3:
			pass
		else:
			more_draws_allowed = true
			draw_cards_to_hands(cards_per_round)
			more_draws_allowed = false
			round_num += 1
	can_play_card = true
	print("can play card?", can_play_card)
	
func player_attack_turn():
	get_node("PlayCardText").modulate.a = 1
	var card_chosen = null
	var player_hand = $"../PlayerHand"
	can_play_card = true
	card_chosen = await get_card_clicked
	
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
		
#Card suits have various effects whether they are played on attack or defense:
# Spades (Attack) -> Ignore effects of armor/shields.
# Spades (Defense) -> Opponent takes 1/2 damage as retalation.
# Hearts (Attack) -> Heal 1/2 of the damage done.
# Hearts (Defense) -> Heal the value of the card.
# Diamonds (Attack) ->
# Diamonds (Defense) -> Gain a shield equal to 1/2 the value (applies after attack is dealt)
# Clubs (Attack) -> You will deal no damage on this turn, but gain a 'clubs bonus' which will deal bonus
# damage on your next attack
# Clubs (Defense) -> You gain 1/2 value as armor. (Reduces next attack by armor amount.)
func handle_card_suit_effects(attacking_card, defending_card, is_player_attack):
	var attacking_suit = attacking_card.card_values[1]
	var attacking_value = attacking_card.card_values[0] * round_num
	var defending_suit = defending_card.card_values[1]
	var defending_value = defending_card.card_values[0]
		
	#Handle attack first
	if attacking_suit == "Clubs":
		if is_player_attack:
			player_clubs_bonus += attacking_value
		else:
			opponent_clubs_bonus += attacking_value
		
	if attacking_suit == "Spades":
		if is_player_attack:
			attacking_value = handle_clubs(attacking_value, "player")
			enemy_hp -= attacking_value
			update_healths()
		else:
			attacking_value = handle_clubs(attacking_value, "enemy")
			player_hp -= attacking_value
			update_healths()
	
	if attacking_suit == "Hearts":
		if is_player_attack:
			attacking_value = handle_clubs(attacking_value, "player")
			attacking_value = max(0, attacking_value - opponent_armor)
			if attacking_value == 0:
				opponent_armor = max(0, opponent_armor - 2)
			else:
				opponent_armor = 0
			change_health(attacking_value, "enemy")
			change_health(floor(attacking_value / 2), "player")
		else:
			attacking_value = handle_clubs(attacking_value, "enemy")
			attacking_value = max(0, attacking_value - player_armor)
			if attacking_value == 0:
				player_armor = max(0, player_armor - 2)
			else:
				player_armor = 0
			change_health(attacking_value, "player")
			change_health(floor(attacking_value / 2), "enemy")
	if attacking_suit == "Diamonds":
		if is_player_attack:
			player_shield += floor(attacking_value / 2)
			attacking_value = handle_clubs(attacking_value, "player")
			attacking_value = max(0, attacking_value - opponent_armor)
			if attacking_value == 0:
				opponent_armor = max(0, opponent_armor - 2)
			else:
				opponent_armor = 0
			change_health(attacking_value, "enemy")
		else:
			opponent_shield += floor(attacking_value / 2)
			attacking_value = handle_clubs(attacking_value, "enemy")
			attacking_value = max(0, attacking_value - player_armor)
			if attacking_value == 0:
				player_armor = max(0, player_armor - 2)
			else:
				player_armor = 0
			change_health(attacking_value, "player")
#Handling defense
	if defending_suit == "Hearts":
		if is_player_attack:
			change_health(- defending_value, "enemy")
		else:
			change_health(- defending_value, "player")
	if defending_suit == "Diamonds":
		if is_player_attack:
			opponent_shield += defending_value
		else:
			player_shield += defending_value
	if defending_suit == "Clubs":
		if is_player_attack:
			opponent_armor += floor(defending_value / 2)
		else:
			player_armor += floor(defending_value / 2)
	if defending_suit == "Spades":
		if is_player_attack:
			change_health(floor(defending_value / 2), "player")
		else:
			change_health(floor(defending_value / 2), "enemy")

func change_health(damage, player):
	if player == "player":
		#Healing
		if damage < 0:
			player_hp = min(player_max_hp, player_hp - damage)
			update_healths()
			return
		var overflow_damage = damage - player_shield
		if overflow_damage < 0:
			player_shield -= damage
			update_healths()
			return
		player_hp -= overflow_damage
		update_healths()
	else:
		if damage < 0:
			enemy_hp = min(enemy_max_hp, enemy_hp - damage)
			update_healths()
			return
		var overflow_damage = damage - opponent_shield
		if overflow_damage < 0:
			opponent_shield -= damage
			update_healths()
			return
		enemy_hp -= overflow_damage
		update_healths()

func handle_clubs(val, player) -> int:
	if player == "player":
		var new_dam = val + player_clubs_bonus
		player_clubs_bonus = 0
		return new_dam
	else:
		var new_dam = val + opponent_clubs_bonus
		opponent_clubs_bonus = 0
		return new_dam
		
func update_healths():
	get_node("EnemyHP").text = "Enemy HP: " + str(enemy_hp)
	get_node("PlayerHP").text = "Your HP: " + str(player_hp)
	get_node("EnemyShield").text = str(opponent_shield)
	get_node("PlayerShield").text = str(player_shield)
	
func end_game():
	get_node("GameOverLabel").modulate.a = 1
	get_tree().paused = true
