extends CardGameManager

const BLACKJACK_VAL = 21

var handTotal

func init_gamerules():
	start_draw_size = 1
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_draw_size = 1
	start_game()
	
	
func start_game():
	more_draws_allowed = true
	$"../Deck".draw_card($"../EnemyHand")
	$"../Deck".draw_card($"../EnemyHand")
	
func get_hand_total():
	var total = 0
	for card in $"../PlayerHand".player_hand:
		total += card.card_values[0]
	$"../PlayerHand/PlayerTotalRichTextLabel".text = str(total)
	return total

func hit():
	$"../Deck".draw_card()
	more_draws_allowed = false
	var hand_total = get_hand_total()
	super.disable_button($"../HitButton")
	if hand_total > BLACKJACK_VAL:
		print("BUST")
	elif handTotal == BLACKJACK_VAL:
		print("BLACKJACK")
	else:
		more_draws_allowed = true
		super.enable_button($"../HitButton")
	
func stand():
	pass

func _on_hit_button_pressed() -> void:
	hit()
	print("hit button")


func _on_stand_button_pressed() -> void:
	print("stand button")
	pass # Replace with function body.
