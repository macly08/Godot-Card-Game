extends Node2D

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = .35

var starting_hand_size = 0
var player_deck = []
var card_data_reference

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../CardGameManager".init_gamerules()
	starting_hand_size = $"../CardGameManager".start_draw_size
	card_data_reference = preload("res://CardData.gd")
	initialize_deck()
	$RichTextLabel.text = str(player_deck.size())
	
#Sets up the deck: 4 suits, 13 cards each, and puts them
#in the 'player_deck' list.
func initialize_deck():
	for i in range (0, 4):
		for j in range (0, 13):
			var new_card = [0, "test"]
			new_card[0] = card_data_reference.card_values[j]
			new_card[1] = card_data_reference.card_suits[i]
			#print("new card added to deck: " + str(new_card[0]) + str(new_card[1]))
			player_deck.append(new_card)
	shuffle_deck()
#	print("start hand size is: ", starting_hand_size)
			
#uses built in shuffle method to randomize the list of cards.
func shuffle_deck():
	player_deck.shuffle()
	
# draws card to playerHand
func draw_card(is_my_card, hand: Node2D = $"../PlayerHand"):
	if !$"../CardGameManager".draw_allowed():
		return
	
	print("drawing card")
	
	#grab the 'top' card of the deck and take it out of the deck
	# TODO crashes when deck has no cards left, make exception
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	# If player last card is drawn, disable the deck and set visibility false
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	#Some of this is from the playlist:
	#https://www.youtube.com/watch?v=2jMcuKdRh2w&list=PLNWIwxsLZ-LMYzxHlVb7v5Xo5KaUV7Tq1&ab_channel=Barry%27sDevelopmentHell
	
	$RichTextLabel.text = '[center]' + str(player_deck.size()) + '[/center]'
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	
	#Display proper info on the card
	var card_image_path = str("res://CardGameResources/Assets/Images/"+str(card_drawn[1])+".png")
	new_card.get_node("SuitImage").texture = load(card_image_path)
	#new_card.get_node("Suit").text = str(card_drawn[1])
	var val_text = ""
	match card_drawn[0]:
		11: val_text = "J"
		12:	val_text = "Q"
		13:	val_text = "K"
		14:	val_text = "A"
		_:	val_text = str(card_drawn[0])
			
	new_card.get_node("Value").text = '[center]' + val_text + '[/center]'
	new_card.card_values = card_drawn
	$"../CardManager".add_child(new_card)
	new_card.name = "Card"
	hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	
	#If the card isn't yours, you can only see the back and you can't click it!
	if !is_my_card:
#		print("not my card")
		new_card.get_node("CardImageBack").z_index = 1
		new_card.get_node("Area2D").process_mode = Node.PROCESS_MODE_DISABLED
	else:
		new_card.get_node("AnimationPlayer").play("card_flip")
		
	return new_card
