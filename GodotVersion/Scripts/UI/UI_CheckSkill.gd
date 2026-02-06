extends Node2D

class_name UI_CheckSkill

signal closed

var rows: Array = []

func _ready() -> void:
	rows = [
		$Background/CardContainer/Row1,
		$Background/CardContainer/Row2,
	]

func set_skill_rows(data_rows: Array) -> void:
	for i in range(rows.size()):
		var row = rows[i]
		if i >= data_rows.size():
			row.visible = false
			continue

		row.visible = true
		var row_data = data_rows[i]
		var card: Card = row.get_node("CardVisual")
		if row_data.has("card_id"):
			card.update_card_info_by_id(int(row_data["card_id"]))
		card.disable_click()

		var skill1: RichTextLabel = row.get_node("Skill1")
		var skill2: RichTextLabel = row.get_node("Skill2")
		skill1.text = str(row_data.get("skill1", ""))
		skill2.text = str(row_data.get("skill2", ""))

func _on_close_button_pressed() -> void:
	closed.emit()
	UIManager.get_instance().destroy_ui("UI_CheckSkill")


