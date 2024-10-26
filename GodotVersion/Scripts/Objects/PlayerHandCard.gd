extends Node2D
class_name PlayerHandCard

var slot_index: int = 0
var card: Card = null
var pos: Vector2
var zindex: int = 0
var is_empty: bool = true

func _init(p_card = null, p_pos = Vector2(), p_zindex = 0, p_is_empty = true):
    self.card = p_card
    self.pos = p_pos
    self.zindex = p_zindex
    self.is_empty = p_is_empty