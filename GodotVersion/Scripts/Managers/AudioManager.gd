extends Node
## 全局音频管理器

class_name AudioManager

# 单例模式
static var instance: AudioManager = null

static var audio_folder: String = "res://Audios/"
static var audio_bgm_folder: String = "res://Audios/BGM/"

# 音频播放器节点
var bgm_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS := 8 # 最大同时播放的音效数量

# 音量控制
var bgm_volume: float = 1.0
var sfx_volume: float = 1.0

func _init() -> void:
	# 单例检查
	if instance != null:
		push_error("AudioManager already exists!")
		return
	instance = self

	name = "AudioManager"
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	add_child(bgm_player)
	# 初始化SFX播放器池
	sfx_players.clear() # 确保数组为空
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		sfx_players.append(player)
		player.name = "SFXPlayer_" + str(i)
		add_child(player)
	# 初始化音量控制
	bgm_volume = 1.0
	sfx_volume = 1.0

	

# 获取单例实例
static func get_instance() -> AudioManager:
	if instance == null:
		instance = AudioManager.new()
	return instance


# 播放背景音乐
# - bgm_file_name: 背景音乐文件名
# - volume: 音量 (默认值为1.0)
func play_bgm(bgm_name: String, volume: float = 1.0) -> void:
	var bgm_path:String = audio_bgm_folder + bgm_name + ".mp3"
	
	print("BGM路径:", bgm_path)
	var audio = load(bgm_path)
	if not audio:
		push_error("BGM不存在: " + bgm_name)
		return
	
	bgm_player.stream = audio
	bgm_player.volume_db = linear_to_db(volume * bgm_volume)
	bgm_player.stream_paused = false
	bgm_player.play()

	print("BGM播放状态:", bgm_player.playing)
	print("当前播放位置:", bgm_player.get_playback_position())


# 播放故事音效
func play_story_sfx(story_id: String) -> void:
	var audio = load(audio_folder + story_id + ".mp3")
	if not audio:
		push_error("音效不存在: " + story_id)
		return
	play_sfx(audio)


# 播放音效
func play_sfx(stream: AudioStream, volume: float = 1.0) -> void:
	var player := _get_available_sfx_player()
	if player == null:
		push_error("没有可用的音效播放器")
		return
	
	player.stream = stream
	player.volume_db = linear_to_db(volume)
	player.play()


# 设置BGM音量
func set_bgm_volume(volume: float) -> void:
	bgm_volume = clampf(volume, 0.0, 1.0)
	if bgm_player.playing:
		bgm_player.volume_db = linear_to_db(bgm_volume)
		print_debug("BGM音量:", bgm_volume)


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
