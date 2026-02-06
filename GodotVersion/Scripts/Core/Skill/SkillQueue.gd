extends RefCounted

class_name SkillQueue

enum QueueType {
	GUARANTEE_APPEAR,
	INCREASE_APPEAR
}

class QueueEntry:
	var queue_type: QueueType
	var owner: Player
	var source_card_id: int
	var target_ids: Array[int]
	var probability: float
	var order: int

	func _init(
		p_queue_type: QueueType,
		p_owner: Player,
		p_source_card_id: int,
		p_target_ids: Array[int],
		p_probability: float,
		p_order: int
	):
		queue_type = p_queue_type
		owner = p_owner
		source_card_id = p_source_card_id
		target_ids = p_target_ids.duplicate()
		probability = p_probability
		order = p_order

var _entries: Array[QueueEntry] = []
var _order_counter: int = 0

func clear() -> void:
	_entries.clear()
	_order_counter = 0

func enqueue_guarantee(owner: Player, source_card_id: int, target_ids: Array[int]) -> void:
	_order_counter += 1
	_entries.append(QueueEntry.new(
		QueueType.GUARANTEE_APPEAR,
		owner,
		source_card_id,
		target_ids,
		1.0,
		_order_counter
	))

func enqueue_increase(owner: Player, source_card_id: int, target_ids: Array[int], probability: float) -> void:
	_order_counter += 1
	_entries.append(QueueEntry.new(
		QueueType.INCREASE_APPEAR,
		owner,
		source_card_id,
		target_ids,
		probability,
		_order_counter
	))

func has_guarantee() -> bool:
	for entry in _entries:
		if entry.queue_type == QueueType.GUARANTEE_APPEAR:
			return true
	return false

func has_increase() -> bool:
	for entry in _entries:
		if entry.queue_type == QueueType.INCREASE_APPEAR:
			return true
	return false

func pop_next_guarantee() -> QueueEntry:
	var best_index := -1
	var best_order := 999999999
	for i in range(_entries.size()):
		var entry = _entries[i]
		if entry.queue_type == QueueType.GUARANTEE_APPEAR and entry.order < best_order:
			best_order = entry.order
			best_index = i

	if best_index == -1:
		return null

	var result = _entries[best_index]
	_entries.remove_at(best_index)
	return result

func pop_next_increase() -> QueueEntry:
	var best_index := -1
	var best_order := 999999999
	for i in range(_entries.size()):
		var entry = _entries[i]
		if entry.queue_type == QueueType.INCREASE_APPEAR and entry.order < best_order:
			best_order = entry.order
			best_index = i

	if best_index == -1:
		return null

	var result = _entries[best_index]
	_entries.remove_at(best_index)
	return result
