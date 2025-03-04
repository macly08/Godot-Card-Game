extends CardGameManager

const BLACKJACK_VAL = 21
const DEALER_MIN	= 17
const dealer_timer	= 0.5

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
	if player_total > BLACKJACK_VAL:
		game_status_text.text = "[center]You're Busted!\nPlay Again?[/center]"
	elif dealer_total > BLACKJACK_VAL:
		game_status_text.text = "[center]Dealer Bust! You WIN!!!\nPlay Again?[/center]"
	elif player_total > dealer_total:
		game_status_text.text = "[center]Wahoo! You WIN!!!\nPlay Again?[/center]"
	elif player_total == dealer_total:
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
	if hand_total > BLACKJACK_VAL:
		print("BUST")
		dealer_turn()
	elif hand_total == BLACKJACK_VAL:
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
	pass # Replace with function body.


func _on_retry_button_pressed() -> void:
	reset_board()
	start_round()
	pass # Replace with function body.
	
	
func dealer_turn():
	# If dealer hasn't revealed first card, reveal it
	if dealer_hand.size() == 2:
		game_timer.start()
		await game_timer
		dealer_hand[0].get_node("AnimationPlayer").play("card_flip")
	# Get dealer's total and play according to rules
	var dealer_total = get_hand_total(dealer_hand, dealer_num_ref)
	if dealer_total >= DEALER_MIN:
		end_round()
	else:
		game_timer.start()
		await game_timer
		more_draws_allowed = true
		var new_card = $"../Deck".draw_card(false, $"../EnemyHand")
		more_draws_allowed = true
		dealer_hand.append(new_card)
		new_card.get_node("AnimationPlayer").play("card_flip")
		
		dealer_turn()
	pass
	
func get_hand_total(hand, label = null):
	var total = 0
	for card in hand:
		var card_val = card.card_values[0]
		if card_val == 14:
			continue
		elif card_val > 10 :
			total += 10
		else:
			total += card_val
	if label:
		label.text = str(total)
		print("set label text")
	return total
