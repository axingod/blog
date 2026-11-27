---
title: 把网易云搬进桌面：AlgerMusicPlayer 上手实录
date: 2026-11-28 14:00:00
categories:
  - 实用软件
tags:
  - 音乐
  - Electron
  - Vue3
  - 开源软件
cover: https://panghu.langzixin.dpdns.org/img/cover/music-player-v8.jpg
description: 一个开源的第三方网易云桌面客户端，Electron + Vue3 写成，自带桌面歌词、EQ 和本地音源服务。这篇记录它长什么样、怎么装、源码怎么跑起来。
---

官方桌面端这几年越做越重，开个歌要等它加载推荐、加载广告位，风扇先转起来。

前阵子翻到一个开源项目 [AlgerMusicPlayer](https://github.com/algerkong/AlgerMusicPlayer)，一个用 Electron + Vue3 写的第三方网易云客户端，本地起服务，界面干净，桌面歌词、EQ 均衡器、迷你模式这些该有的都有。我把它跑了一遍，这篇就记录它到底长什么样、怎么用起来。

## 它是什么

一句话：**把网页版的网易云，装进一个原生窗口里**。

技术上它是个典型的 Electron 应用：

- 前端是 Vue 3 + TypeScript，UI 用 naive-ui，样式走 Tailwind
- 状态管理 Pinia，路由 Vue Router，构建用 electron-vite
- 主进程里跑一个本地 API 服务，登录、歌单、播放地址这些请求都走本地，不走第三方中转
- 打包用 electron-builder，Windows / macOS / Linux 都有产物

所以它不需要你额外开一个服务器，装上就能用。

![首页（浅色）](/img/alger/home-light.jpg)

深色模式下是这样：

![首页（深色）](/img/alger/home-dark.jpg)

## 能力清单

| 能力 | 说明 |
| --- | --- |
| 账号登录 | 扫码或手机号登录，歌单、收藏、播放历史跟着账号走 |
| 音乐库 | 歌单、专辑、MV、排行榜、每日推荐 |
| 沉浸式歌词 | 点左下角封面进入，全屏歌词 |
| 桌面歌词 | 独立窗口，置顶显示，可调字号和颜色 |
| 迷你模式 | 缩成一条小播放条，挂在桌面角落 |
| EQ 均衡器 | 内置频段调节，可存预设 |
| 音乐下载 | 单曲、歌单批量下载，可选音质 |
| 多音源解析 | 每个平台各取所长，可单独指定音源 |
| 快捷键 | 全局或应用内，自定义组合键 |
| 多语言 | 内置多套语言包 |

歌词页确实好看，封面当背景、歌词一行行推上来：

![沉浸式歌词](/img/alger/lyric.jpg)

桌面歌词是单独一个窗口，可以拖到屏幕任何位置：

![桌面歌词](/img/alger/desktop-lyric.jpg)

## 三种用起来的方式

### 一、直接下安装包（推荐给不想折腾的人）

去项目的 [Releases](https://github.com/algerkong/AlgerMusicPlayer/releases) 页面，按系统挑：

- Windows：`.exe` 安装版，或者 `-portable` 免安装版
- macOS：`.dmg`，Intel 和 Apple Silicon 分开
- Linux：`.AppImage` / `.deb`

装完打开、扫码登录，就能用。

### 二、源码跑起来（推荐给想看代码的人）

环境要求：**Node 22 以上**。

```bash
git clone https://github.com/algerkong/AlgerMusicPlayer.git
cd AlgerMusicPlayer
npm install
npm run dev
```

`npm run dev` 会同时起渲染进程和 Electron 主进程，改代码热更新，适合边看边改。

想把界面先当网页看，可以跑：

```bash
npm run dev:web
```

打包成本机安装包：

```bash
npm run build:win    # Windows
npm run build:mac    # macOS
npm run build:linux  # Linux
```

产物在 `dist/` 下。

### 三、网页预览

作者挂了个在线预览：`http://music.alger.fun/`，不想装东西可以先看看界面长什么样。

## 第一次打开该做什么

1. **登录**：右上角头像 -> 扫码，歌单和收藏会自动同步
2. **选音源**：设置里有音源配置，默认会自动挑，遇到某首歌放不出来可以手动指定
3. **开桌面歌词**：播放页右下角有个歌词图标，点开是独立窗口，可以一直置顶
4. **试迷你模式**：窗口右上角的最小化旁边，缩成一条后不挡事
5. **调 EQ**：耳机党可以按口味存一套预设，换设备时切回来

设置页长这样，主题、下载目录、快捷键、音质都在这儿：

![设置页](/img/alger/settings.jpg)

还有个挺实用的小功能：手机扫码可以远程控制桌面端播放，躺床上切歌不用起身。

![远程控制](/img/alger/remote.jpg)

## 技术上的几个点

如果你也想写一个类似的桌面应用，这个项目的结构值得抄：

```
src/
├── main/        # Electron 主进程：窗口、歌词解析、本地服务
├── preload/     # 桥接层，暴露安全 API 给渲染进程
├── renderer/    # Vue 3 应用：组件、store、router、api
├── shared/      # 主进程和渲染进程共用的类型与常量
└── i18n/        # 多语言，主进程和渲染进程各一套入口
```

几个设计上的取舍：

- **本地起服务而不是直连第三方接口**：好处是接口地址、鉴权都在自己手里，也不怕第三方服务哪天关停；代价是启动时要等本地端口就绪
- **主进程负责重活**：歌词时间轴解析、音频解锁、文件下载都放主进程，渲染进程只管画界面，不会因为解析卡住 UI
- **electron-store 存配置**：主题、音量、下载路径这些落盘，重装不丢（除非你清了配置目录）

## 踩坑记录

| 坑 | 表现 | 处理 |
| --- | --- | --- |
| Node 版本太低 | `npm install` 报语法错误 | 升到 Node 22+，我本地是 22.23 |
| `npm install` 卡住 | 一直转圈 | 换国内镜像源，或挂代理重试 |
| 打包后打开白屏 | 窗口出来但没内容 | 先 `npm run build` 再打包，别只跑 builder |
| 桌面歌词不显示 | 点了没反应 | 系统里给应用"辅助功能/屏幕录制"权限（macOS） |
| 某首歌放不出来 | 提示解析失败 | 设置里换一个音源再试 |

## 说在最后

这类第三方客户端的定位很清楚：**学习项目、折腾项目**，作者在 README 里也写明了"仅用于学习交流，禁止商业用途"。音源解析那部分涉及版权边界，用不用、怎么用，自己判断，能支持正版的时候还是支持正版。

对我来说它的价值在两个地方：一是界面确实比官方客户端轻，二是代码结构干净，想学 Electron + Vue3 怎么组织一个完整项目，直接读它的 `src/main` 和 `src/renderer` 比看教程快。

项目地址：<https://github.com/algerkong/AlgerMusicPlayer>
