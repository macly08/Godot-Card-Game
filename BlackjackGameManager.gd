extends CardGameManager

const BLACKJACK_VAL = 21
const DEALER_MIN	= 17
const dealer_timer	= 0.5

var hand_y_pos = 390

var dealer_hand = []

var dealer_num_ref

func init_gamerules():
	start_draw_size = 1
	init_timer(dealer_timer)

func init_timer(t: float):
	game_timer = $"../GameTimer"
	game_timer.one_shot = true
	game_timer.wait_time = t

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super.disable_button($"../EndTurnButton")
	game_status_text = $"../GameStatusRichTextLabel"
	dealer_num_ref = $"../HandLabels/DealerTotalRichTextLabel"
	start_draw_size = 1
	start_round()
	
	
func start_round():
	super.disable_button($"../RetryButton")
	
	more_draws_allowed = true
	dealer_hand.append($"../Deck".draw_card(false, $"../EnemyHand"))
	var new_card = $"../Deck".draw_card(false, $"../EnemyHand")
	new_card.get_node("AnimationPlayer").play("card_flip")
	dealer_hand.append(new_card)
	super.enable_button($"../HitButton")
	super.enable_button($"../StandButton")
	
func end_round():
	var player_total = get_hand_total($"../PlayerHand".player_hand)
	var dealer_total = get_hand_total(dealer_hand)
	var player_score = player_total[1]
	var dealer_score = dealer_total[1]
	if player_total[1] > BLACKJACK_VAL:
		player_score = player_total[0]
	if dealer_total[1] > BLACKJACK_VAL:
		dealer_score = dealer_total[0]
		
	if player_score > BLACKJACK_VAL:
		game_status_text.text = "[center]You're Busted!\nPlay Again?[/center]"
	elif dealer_score > BLACKJACK_VAL:
		game_status_text.text = "[center]Dealer Bust! You WIN!!!\nPlay Again?[/center]"
	elif player_score > dealer_score:
		game_status_text.text = "[center]Wahoo! You WIN!!!\nPlay Again?[/center]"
	elif player_score == dealer_score:
		game_status_text.text = "[center]Push.\nPlay Again?[/center]"
	else: # player_total < dealer_total
		game_status_text.text = "[center]You Lose!\nPlay Again?[/center]"
	super.enable_button($"../RetryButton")
	
	
func reset_board():
	$"../PlayerHand".clear_hand()
	$"../EnemyHand".clear_hand()
	dealer_hand.clear()
	game_status_text.text = ""
	$"../HandLabels/PlayerTotalRichTextLabel".text = str(0)
	dealer_num_ref.text = str(0)

func hit():
	$"../Deck".draw_card(true)
	more_draws_allowed = false
	var label = $"../HandLabels/PlayerTotalRichTextLabel"
	var hand_total = get_hand_total($"../PlayerHand".player_hand, label)
	super.disable_button($"../HitButton")
	super.disable_button($"../StandButton")
	if hand_total[0] > BLACKJACK_VAL:
		print("BUST")
		dealer_turn()
	elif hand_total[0] == BLACKJACK_VAL || hand_total[1] == BLACKJACK_VAL:
		print("BLACKJACK")
		dealer_turn()
	else:
		more_draws_allowed = true
		super.enable_button($"../HitButton")
		super.enable_button($"../StandButton")
	
func stand():
	super.disable_button($"../HitButton")
	super.disable_button($"../StandButton")
	dealer_turn()

func _on_hit_button_pressed() -> void:
	hit()
	print("hit button")

func _on_stand_button_pressed() -> void:
	stand()

func _on_retry_button_pressed() -> void:
	reset_board()
	start_round()
	
func dealer_turn():
	# If dealer hasn't revealed first card, reveal it
	if dealer_hand.size() == 2:
		game_timer.start()
		await game_timer.timeout
		dealer_hand[0].get_node("AnimationPlayer").play("card_flip")
	# Get dealer's total and play according to rules
	var dealer_total = get_hand_total(dealer_hand, dealer_num_ref)
	# if Dealer has reached stop value
	if dealer_total[1] >= DEALER_MIN:
		end_round()
	else:
		game_timer.start()
		await game_timer.timeout
		
		var new_card = $"../Deck".draw_card(false, $"../EnemyHand")
		more_draws_allowed = true
		dealer_hand.append(new_card)
		new_card.get_node("AnimationPlayer").play("card_flip")
		
		dealer_turn()
	pass
	
func get_hand_total(hand, label = null):
	var total = [0, 0]
	for card in hand:
		var card_val = card.card_values[0]
		# If card is an ace
		if card_val == 14:
			total[0] += 1
			total[1] += 11
		# If card is a face card
		elif card_val > 10 :
			total[0] += 10
			total[1] += 10
		else:
			total[0] += card_val
			total[1] += card_val
	# if label arg, set label
	if label:
		if (total[0] != total[1]):
			label.text = str(total[0]) + ", or " + str(total[1])
		else:
			label.text = str(total[0])
		print("set label text")
	return total
