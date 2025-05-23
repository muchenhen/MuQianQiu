extends Resource

class_name Story

var id: int
var name: String
var cards_name: Array[String]
var cards_id: Array[int]
var score: int
var audio_id: String
var finished: bool = false

func _init(p_id: int = 0, p_name: String = "", p_cards_name: Array[String] = [], p_cards_id: Array[int] = [], 
		p_score: int = 0, p_audio_id: String = ""):
	id = p_id
	name = p_name
	cards_name = p_cards_name
	cards_id = p_cards_id
	score = p_score
	audio_id = p_audio_id

func is_finished() -> bool:
	return finished

func mark_as_finished():
	finished = true
	
func check_if_completed(player_card_ids: Array) -> bool:
	if finished:
		return false
		
	var all_cards_present = true
	for card_id in cards_id:
		if player_card_ids.find(card_id) == -1:
			all_cards_present = false
			break
			
	return all_cards_present
