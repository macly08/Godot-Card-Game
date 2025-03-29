extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("BlackjackButton").hide()
	get_node("CardbattleButton").hide()
	get_node("BackButton").hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	get_node("BlackjackButton").show()
	get_node("CardbattleButton").show()
	get_node("BackButton").show()
	get_node("PlayButton").hide()


func _on_back_button_pressed() -> void:
	get_node("BlackjackButton").hide()
	get_node("CardbattleButton").hide()
	get_node("PlayButton").show()
	get_node("BackButton").hide()


func _on_blackjack_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Blackjack.tscn")


func _on_cardbattle_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CardBattle.tscn")
