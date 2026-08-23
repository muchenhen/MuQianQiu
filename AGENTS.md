# AGENTS.md - MuQianQiu (千秋戏) 项目开发指南

> 为 AI 编码助手（Codex/Claude Code 等）提供的项目上下文和工作指南

---

## 🎮 项目概述

**项目名称：** MuQianQiu (千秋戏)

**项目描述：** 《古剑奇谭三》内置游戏《千秋戏》的玩法复刻

**目标平台：** Web、Windows，Android 为规划目标

**许可证：** 素材版权归上海烛龙信息科技有限公司所有

---

## 📁 仓库结构

```
MuQianQiu/
├── GodotVersion/          # [MAIN] Godot 4 版本（当前主开发分支）
│   ├── Scenes/            # 游戏场景 (.tscn)
│   ├── Scripts/           # GDScript 代码
│   │   ├── Core/          # 核心游戏逻辑
│   │   ├── Managers/      # 单例管理器
│   │   ├── Objects/       # 游戏对象
│   │   ├── UI/            # 界面逻辑
│   │   └── Debug/         # 调试工具
│   ├── Tables/            # 数据表配置
│   ├── Audios/            # 音频资源
│   ├── Textures/          # 贴图资源
│   └── project.godot      # Godot 项目配置
├── QianQiuUMGVersion/     # [BRANCH: slua-umg] 虚幻 UMG+slua 版本
├── PythonTools/           # Python 开发工具
├── CSV/                   # 数据表格源文件
├── FLOW/                  # 游戏规则流程图
└── AGENTS.md              # 本文件
```

---

## 🌿 分支说明

| 分支 | 版本 | 引擎 | 语言 | 状态 |
|------|------|------|------|------|
| `main` | Godot 4 | Godot 4.4+ | GDScript | ✅ 主开发分支 |
| `slua-umg` | UMG | Unreal 5.4+ | C++ + slua | 🟡 维护中 |
| `source` | 原生 C++ | Unreal 5.4+ | 纯 C++ | 🟡 维护中 |

**默认工作分支：** `main` (Godot 版本)

---

## 🛠️ 开发环境

### Godot 版本 (main 分支)

```bash
# 要求
- Godot 4.4 或更高版本
- Git

# 启动
1. 克隆仓库：git clone <repo-url>
2. 切换到 main 分支：git checkout main
3. 用 Godot 打开仓库内的 `GodotVersion/project.godot`
```

### UMG 版本 (slua-umg 分支)

```bash
# 要求
- Unreal Engine 5.4+
- Rider for Unreal
- Git

# 启动
1. 切换分支：git checkout slua-umg
2. 初始化子模块：git submodule update --init --recursive
3. 用 Rider 打开 .sln 文件编译
```

### 原生 C++ 版本 (source 分支)

```bash
# 要求
- Unreal Engine 5.4+
- Rider for Unreal
- Git

# 启动
1. 切换分支：git checkout source
2. 用 Rider 打开 .sln 文件编译
```

---

## 📐 代码架构 (Godot 版本)

### Core/ - 核心游戏逻辑

| 文件 | 职责 |
|------|------|
| `AI/AIPerspective.gd` | AI 视角和决策逻辑 |
| `AI/AIPlanner.gd` | AI 行为规划器 |
| `Events/TurnCommand.gd` | 回合命令系统 |
| `Events/TurnEvent.gd` | 回合事件系统 |
| `Match/MatchConfig.gd` | 对局配置 |
| `Match/MatchState.gd` | 对局状态管理 |
| `Match/TurnEngine.gd` | 回合引擎核心 |
| `Skill/SkillCastEvent.gd` | 技能施放事件 |
| `Skill/SkillQueue.gd` | 技能队列管理 |
| `Skill/SkillResolver.gd` | 技能解析器 |

### Managers/ - 单例管理器

| 文件 | 职责 |
|------|------|
| `GameManager.gd` | 游戏主控制器 |
| `GameInstance.gd` | 游戏实例（全局持久化） |
| `CardManager.gd` | 卡牌管理 |
| `CardExchangeManager.gd` | 卡牌交换逻辑 |
| `SkillManager.gd` | 技能管理 |
| `UIManager.gd` | UI 协调器 |
| `AudioManager.gd` | 音频管理 |
| `AnimationManager.gd` | 动画管理 |
| `InputManager.gd` | 输入管理 |
| `ScoreManager.gd` | 分数管理 |
| `StoryManager.gd` | 剧情管理 |
| `TableManager.gd` | 数据表管理 |

### Objects/ - 游戏对象

| 文件 | 职责 |
|------|------|
| `Card.gd` | 卡牌基类 |
| `CardSkill.gd` | 卡牌技能 |
| `AIAgent.gd` | AI 代理 |
| `GridBox.gd` | 网格布局容器 |
| `HorizontalBox.gd` | 水平布局容器 |
| `CheckButton.gd` | 复选按钮 |

---

## 🔧 开发规范

### GDScript 编码风格

```gdscript
# 类名：PascalCase
class_name CardManager

# 变量：snake_case
var card_count: int = 0
var is_player_turn: bool = false

# 常量：UPPER_SNAKE_CASE
const MAX_CARDS = 10
const CARD_TYPES = ["character", "skill", "equipment"]

# 函数：snake_case
func add_card(card: Card) -> void:
    pass

# 私有函数：前缀下划线
func _internal_process() -> void:
    pass

# Godot 生命周期：前缀下划线
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass
```

### 注释规范

```gdscript
## 文档注释（双井号）
## 卡牌基类，定义所有卡牌的通用属性和行为
class_name Card

## 卡牌唯一标识
@export var card_id: String

## 初始化卡牌
## @param data 卡牌数据字典
func init_card(data: Dictionary) -> void:
    ## 本地变量注释
    var parsed_data = _parse_data(data)
    pass
```

### 场景与 UI 组织

```
GodotVersion/
├── Scenes/
│   └── SC_Game.tscn                 # 主场景入口
├── UI/                              # UI 场景
│   ├── UI_Start.tscn
│   ├── UI_Main.tscn
│   └── UI_SelectInitSkillCard.tscn
└── Scripts/
    ├── UI/                          # UI 脚本
    └── Objects/Card.tscn            # 卡牌预制件
```

---

## 🎯 核心游戏机制

### 回合流程

```
1. 回合开始 → TurnEngine.start_turn()
2. 抽牌阶段 → CardManager.draw_card()
3. 行动阶段 → InputManager.handle_input()
4. 技能施放 → SkillResolver.resolve()
5. 回合结束 → TurnEngine.end_turn()
```

### AI 决策流程

```
1. 收集信息 → AIPerspective.gather()
2. 评估局面 → AIPlanner.evaluate()
3. 生成候选 → AIPlanner.generate_candidates()
4. 选择最优 → AIPlanner.select_best()
5. 执行动作 → TurnCommand.execute()
```

### 技能系统

```
SkillCastEvent (事件触发)
    ↓
SkillQueue (入队等待)
    ↓
SkillResolver (解析执行)
    ↓
效果应用 (状态/伤害/抽牌等)
```

---

## 📊 数据管理

### CSV 数据表

位置：`CSV/` 和 `GodotVersion/Tables/`

- 卡牌数据
- 技能配置
- 角色属性
- 游戏规则参数

使用 `TableManager.gd` 进行加载和查询。

### 存档系统

位置：`GodotVersion/` (运行时生成)

- 玩家进度
- 解锁内容
- 统计数据

---

## 🧪 调试工具

### DebugController.gd

```gdscript
var debug_controller = DebugController.get_instance()
debug_controller.force_card_to_player_a_enabled = true
```

调试入口必须受 `OS.is_debug_build()` 或等价构建条件保护。正式发布版不得显示 Debug 选卡、定向发牌等开发控件。

### 日志输出

```gdscript
# 使用 Godot 内置打印
print("普通日志")
print_rich("[color=red]彩色日志[/color]")
push_warning("警告")
push_error("错误")
```

---

## 🚀 构建发布

### Web 版本

```bash
godot4 --headless --path GodotVersion --editor --quit
godot4 --headless --path GodotVersion --export-release Web
```

- 导出目录：`GodotVersion/Packages/web/`
- Web 发布必须使用 `Font/DefaultTheme.tres` 中的项目内字体，不可依赖浏览器系统字体回退。
- 更新 UI 文案或数据表文本后，应重新运行 `PythonTools/FontSimplify.py` 并检查字体缺字。
- 线上公开地址：`https://qianqiuxi.lemongamestudio.cn/`
- 线上资源使用版本化文件名，并由 `index.html` 跳转到当前版本入口，以避免浏览器缓存混用。

### Windows 版本

```bash
godot4 --headless --path GodotVersion --export-release "Windows Desktop"
```

### Release 约定

- 发布版本采用 `vMAJOR.MINOR.PATCH` 标签，项目版本同步写入 `GodotVersion/project.godot`。
- GitHub Release 至少包含 Web 和 Windows x64 压缩包及 SHA-256 校验值。
- 发布前依次完成：Godot 解析、release 导出、Web 浏览器实测、暂存区审计、远程部署验证、推送和 Release 创建。
- 部署连接和目标路径只从本机受保护配置读取，不得写入仓库、提交信息或 Release 说明。

### Android 版本

```bash
# 需要配置 Android SDK
1. 安装 Android 构建模板
2. 配置 SDK 路径
3. 添加 Android 预设
4. 导出 APK
```

---

## 🔌 扩展开发

### 添加新卡牌

1. 在 `Tables/` 添加卡牌数据
2. 继承 `Card.gd` 创建卡牌逻辑
3. 在 `CardManager.gd` 注册
4. 添加 UI 表现（可选）

### 添加新技能

1. 在 `Tables/` 添加技能配置
2. 继承 `CardSkill.gd` 或使用现有技能
3. 在 `SkillResolver.gd` 添加处理逻辑
4. 测试技能队列和效果

### 添加新 AI 行为

1. 扩展 `AIPlanner.gd` 的评估函数
2. 添加新的决策规则
3. 调整权重参数
4. 测试 AI 表现

---

## ⚠️ 注意事项

### 版权相关

- **所有美术、音频、文本素材均为上海烛龙所有**
- 本项目为非商业粉丝作品
- 不要将素材用于商业用途
- 分发时保留版权声明

### 凭据与隐私

- 禁止提交或输出服务器地址、后台用户名、SSH 私钥、令牌、密码及本机密钥路径。
- 禁止把 `.env`、`*.pem`、`*.key`、`*.ppk`、`*.p12`、`*.pfx`、`id_rsa*`、`id_ed25519*` 或 `deploy.local.*` 加入 Git。
- 部署前后只在日志中记录公开站点地址和非敏感校验结果。
- 提交前使用 `git diff --cached` 和 `git status --short` 审计暂存区，发现疑似凭据必须停止发布。

### 开发限制

- 玩法规则遵循原作，不接受修改建议
- 想改规则请 fork 仓库
- 保持代码与主分支同步

### 性能考虑

- Web 版本注意内存使用
- 卡牌效果避免无限循环
- AI 计算控制时间复杂度

---

## 📚 相关资源

- [Godot 文档](https://docs.godotengine.org/)
- [GDScript 参考](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_reference.html)
- [项目 GitHub](https://github.com/muchenhen/MuQianQiu)
- [项目看板](https://github.com/muchenhen?tab=projects&type=beta)

---

## 🤖 AI 助手工作流

### 代码审查清单

- [ ] 遵循 GDScript 命名规范
- [ ] 添加适当的文档注释
- [ ] 检查内存泄漏（引用计数）
- [ ] 测试边界条件
- [ ] 确认与现有系统兼容

### 常见任务模板

**修复 Bug:**
```
1. 复现问题
2. 定位相关代码（使用 grep/搜索）
3. 分析根本原因
4. 编写修复代码
5. 添加测试用例
6. 验证修复
```

**添加功能:**
```
1. 理解需求
2. 设计实现方案
3. 创建/修改相关文件
4. 集成到现有系统
5. 测试功能
6. 更新文档
```

**代码重构:**
```
1. 识别改进点
2. 确保有测试覆盖
3. 小步重构
4. 每步验证
5. 更新注释和文档
```

---

*最后更新：2026-08-24*
*适用于：Godot 4.4+ 版本*
