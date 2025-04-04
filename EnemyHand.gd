extends Node2D

const CARD_WIDTH = 128
const DEFAULT_CARD_MOVE_SPEED = 0.1

var hand_y_pos = 390
var player_hand = []
var center_screen_x

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hand_y_pos = $"../CardGameManager".hand_y_pos
	center_screen_x = get_viewport().size.x / 2
	# hand_y_pos = $".".global_position[1]
	print("center screen_x is:", center_screen_x )
	
func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, DEFAULT_CARD_MOVE_SPEED)
	
func update_hand_positions(speed):
	for i in range(player_hand.size()):
		# Get new card position based on the index.
		var new_position = Vector2(calculate_card_position(i), hand_y_pos)
		var card = player_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed)
		
func calculate_card_position(index):
	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	if !center_screen_x: center_screen_x = get_viewport().size.x / 2
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset
	
func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		card.queue_free()
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
		
func clear_hand():
	for i in range(player_hand.size() -1, -1, -1):
		remove_card_from_hand(player_hand[i])
		
func pick_random_card() -> int:
	var rng = RandomNumberGenerator.new()
	var card = int(rng.randf_range(0, player_hand.size()))
	print(card)
	return card

func play_card(card) -> int:
	var val = player_hand[card].card_values[0]
	remove_card_from_hand(player_hand[card])
	return val
	
