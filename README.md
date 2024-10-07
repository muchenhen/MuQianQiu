# 千秋戏

## Readme更新于2024-10-7 18:05:32

---

## 仓库介绍：

本项目是对《古剑奇谭三：梦付千秋星垂野》中的内置游戏《千秋戏》的玩法复刻。  
目标是最终制作出包括web、安卓、windows三平台的游戏版本，并且可以支持联机游戏，允许玩家自定义一些游戏组合


本项目没有什么目的，就是想做

玩法采用单机内的版本  
不接受任何玩法相关的建议和意见，想改玩法规则的话自己fork。


本仓库中目前一共有三个不同版本的具体项目

### UMG+slua

QianQiuUMGVersion\SluaVersion

该目录下的项目是使用UMG制作，使用slua作为脚本语言来进行开发

需要虚幻引擎5.4+以上版本

### 原生虚幻C++

QianQiu

该目录下使用纯C++进行开发，使用3D场景，卡牌使用Actor基类来进行实现，没有使用脚本语言

### Godot 4

GodotVersion

该目录下是使用Godot 4版本进行开发的，脚本语言使用了GD Script，为了能进行web版本的发布。

需要Godot 4.3以上版本

---

## 项目管理：

https://github.com/muchenhen?tab=projects&type=beta

## 其他

CSV目录下是一些数据表格

FLOW目录下是游戏规则流程图

PythonTools目录下是一些开发过程中用到的Python工具

Texture目录下是贴图资源

## 拉取指南

将整个仓库拉取到本地后，使用`git submodule update --init --recursive`来拉取子模块，slua版本下依赖了我自己fork的slua仓库。

纯C++版本直接使用Rider打开sln文件之后编译即可。

UMG+slua版本需要确保slua的Plugins存在，然后使用Rider打开sln文件之后编译即可。

Godot版本可以使用最新的稳定发布版本直接打开，或者自行编译4.3以上的版本。

## 注意

**所有相关素材均为原作公司上海烛龙信息科技有限公司所有。**

## **感谢**

https://github.com/bubububaoshe/bubububaoshe.github.io

使用了该项目中总结的一些文本数据

感谢B站UP@[伊织大西瓜](https://space.bilibili.com/11527414/)提供的白荆版本特殊卡卡面

---

本项目使用JetBrains Rider进行开发，IDE License由JetBrains 开源项目申请提供

<p>
<a href="https://www.jetbrains.com/"/>
<img src ="jb_beam.png" align="middle" width=25%/>
</a>
<a href="https://www.jetbrains.com/rider/"/>
<img src ="Rider.png" align="middle" width=25%/>
</a>
<a href="https://www.jetbrains.com/lp/rider-unreal/"/>
<img src ="Rider_icon.png" align="middle" width=25%/>
</a>
</p>

<font size = 5> [**JetBrains 开源项目支持申请链接**](https://www.jetbrains.com/lp/rider-unreal/)</font>

