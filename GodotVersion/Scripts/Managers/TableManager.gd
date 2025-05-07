extends Node

class_name TableManager

var tables = {}

# 单例实例
static var instance: TableManager = null

# 获取单例实例
static func get_instance() -> TableManager:
	if instance == null:
		instance = TableManager.new()
		instance.initialize()
	return instance

func initialize() -> void:
	load_csv("res://Tables/Cards.txt")
	load_csv("res://Tables/Stories.txt")
	load_csv("res://Tables/Skills.txt")


# 加载CSV文件并创建可索引的结构
func load_csv(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		printerr("Failed to open file: ", file_path)
		return

	var headers = []
	var data = {}
	var line_number = 0

	while not file.eof_reached():
		var line = file.get_csv_line()
		if line_number == 0:
			headers = line
		else:
			var id = int(line[0])  # 确保 ID 是整数
			var row = {}
			for i in range(1, min(line.size(), headers.size())):
				row[headers[i]] = parse_value(line[i])
			data[id] = row
		
		line_number += 1

	file.close()

	var table_name = file_path.get_file().get_basename()
	tables[table_name] = data
	print("Loaded table: ", table_name)

# 解析值，尝试转换为适当的类型
func parse_value(value: String):
	if value.is_valid_int():
		return value.to_int()
	elif value.is_valid_float():
		return value.to_float()
	elif value.to_lower() == "true":
		return true
	elif value.to_lower() == "false":
		return false
	else:
		return value

# 获取表
func get_table(table_name: String) -> Dictionary:
	return tables.get(table_name, {})

# 获取行
func get_row(table_name: String, id: int) -> Dictionary:
	var table = get_table(table_name)
	return table.get(id, {})

# 获取特定值
func get_value(table_name: String, id: int, column: String):
	var row = get_row(table_name, id)
	return row.get(column)
