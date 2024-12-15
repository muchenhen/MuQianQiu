extends Node
## 全局音频管理器

class_name AudioManager

# 单例模式
static var instance: AudioManager = null

# 音频播放器节点
var bgm_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS := 8  # 最大同时播放的音效数量

# 音量控制
var bgm_volume: float = 1.0
var sfx_volume: float = 1.0

# 音频缓存
var audio_cache := {}

func _init() -> void:
    if instance != null:
        push_error("AudioManager already exists!")
        return
    instance = self
    
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
    return instance

# 播放背景音乐
func play_bgm(stream: AudioStream, volume: float = 1.0) -> void:
    bgm_player.stream = stream
    bgm_player.volume_db = linear_to_db(volume * bgm_volume)
    bgm_player.play()

# 播放音效
func play_sfx(stream: AudioStream, volume: float = 1.0) -> void:
    var player := _get_available_sfx_player()
    if player == null:
        return
    
    player.stream = stream
    player.volume_db = linear_to_db(volume * sfx_volume)
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