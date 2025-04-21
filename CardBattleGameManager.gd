extends CardGameManager

var hand_y_pos = 120
var player_hp = 50
var player_max_hp = 50
var enemy_hp = 50
var enemy_max_hp = 50
var round_num = 1
var cards_per_round = 5
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

const turn_timer = 1

const player_played_card_x = 960
const player_played_card_y = 600
const enemy_played_card_x = 960
const enemy_played_card_y = 400

func init_gamerules():
	init_timer(turn_timer)

func init_timer(t: float):
	game_timer = $"../GameTimer"
	game_timer.one_shot = true
	game_timer.wait_time = t
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()
		
func start_game():
	get_node("../ReplayButton").hide()
	get_node("../ExitButton").hide()
	can_play_card = false
	more_draws_allowed = true
	draw_cards_to_hands(cards_per_round)
	more_draws_allowed = false
	round_num = 1
	
	get_node("AttackIcon").modulate.a = 0
	get_node("DefendIcon").modulate.a = 0
	var whose_turn = coin_flip()
	if whose_turn == 1:
		get_node("AnimationPlayer").play("player_attack_icons")
	else: get_node("AnimationPlayer").play("player_defend_icons")
	var round_label = get_node("RoundLabel")
	var str = ""
	for i in range(0, round_num):
		str += "I"
	round_label.text = "[center]" + "Round " + str + "[/center]"
	round_label.modulate.a = 1
	
	game_timer.start()
	await game_timer.timeout
	game_timer.start()
	await game_timer.timeout
	game_timer.start()
	await game_timer.timeout
	
	round_label.modulate.a = 0
	get_node("AttackIcon").modulate.a = 1
	get_node("DefendIcon").modulate.a = 1
	if whose_turn == 1:
		print("player starts attack")
		player_attack = true
		opponent_attack = false
		#change_play_text("Attack")
	else: 
		print("opponent starts attack")
		opponent_attack = true
		player_attack = false
		#change_play_text("Defense")
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
		
func change_play_text(condition):
	var card_text = get_node("PlayCardText")
	card_text.text = "[center]" + "Play a card for " + str(condition) + "[/center]"
	card_text.modulate.a = 1

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
	
	opponents_hand.animate_card_to_position(opponents_card, Vector2(enemy_played_card_x, enemy_played_card_y), .5)
	players_hand.animate_card_to_position(players_card, Vector2(player_played_card_x, player_played_card_y), .5)
	#players_card.set_global_position(Vector2(player_played_card_x, player_played_card_y))
	#opponents_card.set_global_position(Vector2(enemy_played_card_x, enemy_played_card_y))
	
	game_timer.start()
	await game_timer.timeout
	
	opponents_card.get_node("AnimationPlayer").play("card_flip")
	
	game_timer.start()
	await game_timer.timeout
	
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
		get_node("AnimationPlayer").play("player_defense_icons")
		#change_play_text("Defense")
	else:
		var attacking_card = opponents_card
		var defending_card = players_card
		handle_card_suit_effects(attacking_card, defending_card, false)
		players_hand.remove_card_from_hand(defending_card)
		opponents_hand.remove_card_from_hand(attacking_card)
		player_attack = true
		opponent_attack = false
		get_node("AnimationPlayer").play("player_attack_icons")
		#change_play_text("Attack")
	#Out of cards: draw more and increment round number.
	if players_hand.player_hand.size() == 0:
		if round_num == 3:
			if player_hp > enemy_hp:
				game_over("win")
			elif player_hp < enemy_hp:
				game_over("lose")
			else: game_over("tie")
		else:
			round_num += 1
			var round_label = get_node("RoundLabel")
			var str = ""
			for i in range(0, round_num):
				str += "I"
			round_label.text = "[center]" + "Round " + str + "[/center]"
			round_label.modulate.a = 1
			get_node("RoundLabel/AnimationPlayer").play("shake_text")
			
			game_timer.start()
			await game_timer.timeout
			if round_num == 3: 
				get_node("Round3Text").modulate.a = 1
				get_node("Round3Text/AnimationPlayer").play("shake_text")
			game_timer.start()
			await game_timer.timeout
			game_timer.start()
			await game_timer.timeout
			round_label.modulate.a = 0
			get_node("Round3Text").modulate.a = 0
			more_draws_allowed = true
			draw_cards_to_hands(cards_per_round)
			more_draws_allowed = false
	can_play_card = true
	
	print("can play card?", can_play_card)
		
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
	var attacking_base_value = attacking_card.card_values[0]
	var attacking_value = attacking_card.card_values[0]
	var defending_suit = defending_card.card_values[1]
	var defending_value = defending_card.card_values[0]
	
	if round_num == 3:
		attacking_value *= 2
	#Handle attack first
	if attacking_suit == "Clubs":
		if is_player_attack:
			player_clubs_bonus += attacking_base_value
		else:
			opponent_clubs_bonus += attacking_base_value
	if attacking_suit == "Spades":
		if is_player_attack:
			attacking_value = handle_clubs(attacking_value, "player")
			enemy_hp -= attacking_value
			animate_healths("enemy", "red")
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
	update_healths()
	
	game_timer.start()
	await game_timer.timeout
	
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
			opponent_armor = max(floor(defending_value / 2), opponent_armor)
		else:
			player_armor = max(floor(defending_value / 2), player_armor)
	if defending_suit == "Spades":
		if is_player_attack:
			change_health(floor(defending_value / 2), "player")
		else:
			change_health(floor(defending_value / 2), "enemy")
			
	update_healths()
	game_timer.start()
	await game_timer.timeout
	if player_hp <= 0:
		game_over("lose")
	if enemy_hp <= 0:
		game_over("win")
	if player_hp <= 0 and enemy_hp <= 0:
		game_over("tie")

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
		var tween = get_tree().create_tween()
		tween.tween_property(get_node("PlayerHP"), "modulate", Color.RED, .1)
		tween.tween_property(get_node("PlayerHP"), "modulate", Color.WHITE, .1)
		get_node("PlayerLifeIcon/AnimationPlayer").play("heart_shake")
		player_shield = 0
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
		var tween = get_tree().create_tween()
		tween.tween_property(get_node("EnemyHP"), "modulate", Color.RED, .1)
		tween.tween_property(get_node("EnemyHP"), "modulate", Color.WHITE, .1)
		opponent_shield = 0
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
		
func animate_healths(player, color):
	if player == "enemy" and color == "red":
		get_node("AnimationPlayer").play("enemy_take_damage")
	
func update_healths():
	get_node("EnemyHP").text = "[center]" + str(enemy_hp) + "[/center]"
	get_node("PlayerHP").text = "[center]" + str(player_hp) + "[/center]"
	get_node("EnemyShield").text = "[center]" + str(opponent_shield) + "[/center]"
	get_node("PlayerShield").text = "[center]" + str(player_shield) + "[/center]"
	get_node("PlayerArmor").text = "[center]" + str(player_armor) + "[/center]"
	get_node("EnemyArmor").text = "[center]" + str(opponent_armor) + "[/center]"
	get_node("EnemyAttack").text = "[center]" + str(opponent_clubs_bonus) + "[/center]"
	get_node("PlayerAttack").text = "[center]" + str(player_clubs_bonus) + "[/center]"
	if player_shield > 0:
		$"PlayerLifeIcon/PlayerLifeShield".modulate.a = 1
	else:
		$"PlayerLifeIcon/PlayerLifeShield".modulate.a = 0
		
	if opponent_shield > 0:
		$"EnemyLifeIcon/EnemyLifeShield".modulate.a = 1
	else:
		$"EnemyLifeIcon/EnemyLifeShield".modulate.a = 0
	var full_hp_icon = load("res://CardGameResources/Assets/Images/LifeIconFull.png")
	var half_hp_icon = load("res://CardGameResources/Assets/Images/LifeIconHalf.png")
	var empty_hp_icon = load("res://CardGameResources/Assets/Images/LifeIconLow.png")
	if player_hp >= 30:
		get_node("PlayerLifeIcon").texture = full_hp_icon
	elif player_hp < 30 and player_hp > 10:
		get_node("PlayerLifeIcon").texture = half_hp_icon
	else: get_node("PlayerLifeIcon").texture = empty_hp_icon
	if enemy_hp >= 30:
		get_node("EnemyLifeIcon").texture = full_hp_icon
	elif enemy_hp < 30 and enemy_hp > 10:
		get_node("EnemyLifeIcon").texture = half_hp_icon
	else: get_node("EnemyLifeIcon").texture = empty_hp_icon
	
func game_over(condition):
	if condition == "win":
		get_node("GameOverLabel").text = "[center]You Win![/center]"
	elif condition == "lose":
		get_node("GameOverLabel").text = "[center]You Lose."
	else: get_node("GameOverLabel").text = "[center]It's a draw."
	get_node("GameOverLabel").modulate.a = 1
	get_node("PlayCardText").modulate.a = 0
	get_node("AttackIcon").queue_free()
	get_node("DefendIcon").queue_free()
	can_play_card = false
	get_node("../ReplayButton").show()
	get_node("../ExitButton").show()


func _on_replay_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenuScene.tscn")
