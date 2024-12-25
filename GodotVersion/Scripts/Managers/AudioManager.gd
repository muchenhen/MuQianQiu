extends Node
## 全局音频管理器

class_name AudioManager

# 单例模式
static var instance: AudioManager = null

static var audio_folder:String = "res://Audios/"
static var audio_bgm_folder:String = "res://Audios/BGM/"

# 音频播放器节点
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS := 8  # 最大同时播放的音效数量

# 音量控制
var bgm_volume: float = 1.0
var sfx_volume: float = 1.0

# 音频缓存
var audio_cache := {}

func _init() -> void:
	# 单例检查
	if instance != null:
		push_error("AudioManager already exists!")
		return
	instance = self
		
	# 初始化SFX播放器池
	sfx_players.clear()  # 确保数组为空
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		sfx_players.append(player)
		add_child(player)
	
	# 初始化音量控制
	bgm_volume = 1.0
	sfx_volume = 1.0
	
	# 初始化音频缓存
	audio_cache.clear()  # 确保字典为空
	
	# 确保音频文件夹路径正确结尾
	if not audio_folder.ends_with("/"):
		audio_folder += "/"
	if not audio_bgm_folder.ends_with("/"):
		audio_bgm_folder += "/"
	
func _ready() -> void:
	# 初始化BGM播放器
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	
	# 初始化SFX播放器池
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		sfx_players.append(player)
		add_child(player)

# 获取单例实例
static func get_instance() -> AudioManager:
	if instance == null:
		instance = AudioManager.new()
	return instance

# 播放背景音乐
# - bgm_file_name: 背景音乐文件名
# - volume: 音量 (默认值为1.0)
func play_bgm(bgm_file_name: String, volume: float = 1.0) -> void:
	var bgm_audio_file = audio_bgm_folder + bgm_file_name + ".ogg"
	
	# 验证文件是否存在
	if not FileAccess.file_exists(bgm_audio_file):
		push_error("BGM文件不存在: " + bgm_audio_file)
		return
		
	# 添加错误处理
	var stream = load(bgm_audio_file)
	if stream == null:
		push_error("无法加载BGM文件: " + bgm_audio_file)
		return
		
	# 类型检查
	if not (stream is AudioStream):
		push_error("加载的文件不是音频文件: " + bgm_audio_file)
		return
		
	bgm_player.stream = stream

	# 调试音量设置
	print("当前BGM音量设置:")
	print("- 输入音量:", volume)
	print("- bgm_volume:", bgm_volume)
	print("- 最终音量(db):", linear_to_db(volume * bgm_volume))
	
	# 确保音量不为静音
	if volume * bgm_volume <= 0:
		push_warning("BGM音量为0或负值")
	
	# 设置音量并播放
	bgm_player.volume_db = linear_to_db(volume * bgm_volume)
	
	# 确保没有静音
	bgm_player.stream_paused = false
	
	# 验证AudioBus设置
	if AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")):
		push_warning("主音频总线已静音")
	
	bgm_player.play()
	
	# 播放状态验证
	print("BGM播放状态:", bgm_player.playing)
	print("当前播放位置:", bgm_player.get_playback_position())

func print_current_bgm_state():
	print("当前正在播放的BGM:", bgm_player.stream)
	print("- 播放状态:", bgm_player.playing)
	print("当前BGM音量设置:")
	print("- bgm_volume:", bgm_volume)


# 播放故事音效
func play_story_sfx(story_id: String) -> void:
	var story_audio_file = audio_folder + story_id + ".wav"
	var stream := load(story_audio_file) as AudioStream
	play_sfx(stream)

# 播放音效
func play_sfx(stream: AudioStream, volume: float = 1.0) -> void:
	var player := _get_available_sfx_player()
	if player == null:
		return
	
	player.stream = stream
	player.volume_db = linear_to_db(volume)
	player.play()

# 设置BGM音量
func set_bgm_volume(volume: float) -> void:
	bgm_volume = clampf(volume, 0.0, 1.0)
	if bgm_player.playing:
		bgm_player.volume_db = linear_to_db(bgm_volume)

# 设置音效音量
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)

# 停止背景音乐
func stop_bgm() -> void:
	bgm_player.stop()

# 暂停背景音乐
func pause_bgm() -> void:
	bgm_player.stream_paused = true

# 恢复背景音乐
func resume_bgm() -> void:
	bgm_player.stream_paused = false

# 获取可用的音效播放器
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return null
