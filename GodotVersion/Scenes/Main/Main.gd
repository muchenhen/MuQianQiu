# res://Main.gd
extends Node

# 持有所有全局管理器的引用
var settings_manager
var audio_manager
var table_manager
var game_instance_manager # 这个很重要，后面会讲

func _ready():
	# 1. 实例化所有全局管理器
	settings_manager = SettingsManager.new()
	audio_manager = AudioManager.new(settings_manager) # 音频需要设置信息
	table_manager = TableManager.new()
	game_instance_manager = GameInstanceManager.new(table_manager)

	# 2. 将它们添加为子节点，以便在需要时访问
	add_child(settings_manager)
	add_child(audio_manager)
	add_child(table_manager)
	add_child(game_instance_manager)

	# 3. 加载初始数据
	settings_manager.load_settings()
	table_manager.load_data_from_csv()

	# 4. 连接UI信号
	var main_menu = $UILayer/MainMenu
	main_menu.start_single_player.connect(_on_start_single_player_pressed)

# 当MainMenu界面发出“开始单机游戏”信号时被调用
func _on_start_single_player_pressed():
	# 显示单机模式的设置界面
	# (隐藏主菜单，显示单机设置菜单的逻辑...)
	var single_player_setup_menu = load("res://scenes/ui/SinglePlayerSetup.tscn").instantiate()
	$UILayer.add_child(single_player_setup_menu)

	# 连接新菜单的信号
	single_player_setup_menu.game_start_requested.connect(game_instance_manager.start_new_single_player_game)
