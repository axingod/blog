---
title: 让 Windows 长出苹果的灵魂：MacDock 3.2 上手实录
date: 2026-11-28 16:20:00
categories:
  - 实用项目
tags:
  - Windows
  - 桌面美化
  - C++
  - 开源软件
cover: https://panghu.langzixin.dpdns.org/img/cover/macdock-v8.jpg
description: 一个纯 C++20 写的 Windows 桌面套件，核心只有 1.48MB，静止 0% CPU，把 macOS 的 Dock、灵动岛、台前调度、控制中心整套搬到 Windows 上。这篇记录它长什么样、怎么装、源码怎么编。
---

Windows 的桌面不是不能看，是看久了会觉得它对自己没什么想法。

想美化，能选的方案大多两头堵：要么是几百 MB 的套壳软件，开起来风扇先转；要么是改系统主题文件，崩了还得重装。真正"轻"的方案几乎不存在。

直到翻到 [MacDock](https://github.com/wanghcongcong-lulu/MacDock)，一个用纯 C++20 写出来的 Windows 桌面套件：核心单文件 **1.48 MB**，零外部 DLL，静止时 CPU 占用 0.0%，装完还能一键无损退出、还原成原来的 Windows。这个体量放在 2026 年，本身就挺反常识。

## 它是什么

一句话：**把 macOS 的那套桌面逻辑，原生搬进 Windows 里**。

不是模拟，也不是截图糊上去——它直接吃 Win32 + Direct3D 11 + Direct2D 1.1 + Windows.UI.Composition，自己画界面、自己算动画、自己接管窗口最小化。所以你看到的液态玻璃、鱼眼缩放、丝滑漏斗，全是真渲染出来的，不是贴图。

![主桌面与程序坞](/img/macdock/hero-desktop.jpg)

底部是 Dock，顶部是原色菜单栏，右上角那个黑色胶囊是灵动岛——它同时接管了 Windows 的通知，右下角那些弹窗会被统一挪到右上角优雅地弹出来。

## 能力清单

项目 README 里列了十条，我按实际用起来的感觉归了一下：

| 能力 | 实际体验 |
| --- | --- |
| iOS 26 液态玻璃 | 程序坞、菜单栏、控制中心、通知卡片统一玻璃质感，多层模糊 + 边缘高光，鼠标悬停有物理阻尼感 |
| 原色后台托盘 | 隐藏原生任务栏后，常驻后台的软件图标仍按原色显示，可折叠、可右键固定 |
| 双形态灵动岛 | 胶囊 / MacBook 刘海两种形态切换，内置实时声波频谱和悬停音乐控台 |
| 通知接管 | 拦截 Win11 原生右下角弹窗，改从右上角弹出 |
| 贴顶控制中心 | 点顶栏按钮，面板直接在该按钮正下方展开，电池图标里直接嵌剩余电量 |
| 3D 台前调度 | 左侧壁纸悬浮倾斜的实时窗口预览，点一下切换主舞台，还能顶替 `Alt + Tab` |
| Genie 漏斗最小化 | 窗口最小化瞬间被"咻"地吸进 Dock 图标，走 VSync，不靠补帧糊 |
| Dock 可编辑 | 拖拽排序、烟雾移除、5 套皮肤，右侧下载/托盘/电源模块也能拖 |
| 网易云歌词同步 | 双引擎（网易云时间轴 + LRCLIB），点音乐胶囊能唤起播放器 |
| 8 款桌面组件 | 指针时钟、天气、月历、CPU/内存监控、便签、电池、黑胶歌词、番茄钟 |
| 启动台 + Spotlight | `Alt + Space` 呼启动台，`Alt + Q` 呼聚焦搜索，支持拼音首字母 |
| 全局红黄绿 | 可选给所有窗口左上角加 macOS 三色按钮，关掉即还原 |

控制中心和托盘长这样：

![控制中心与托盘](/img/macdock/control-center-tray.jpg)

灵动岛做成 MacBook 刘海形态时，通知就从头顶那块"缺口"里滑出来：

![双形态灵动岛与通知](/img/macdock/dynamic-island-notif.jpg)

台前调度是我用得最多的一个。左边一排窗口斜着悬在壁纸上，像翻卡片一样：

![3D 台前调度](/img/macdock/stage-manager-3d.jpg)

最小化那一瞬间的漏斗动画：

![Genie 神奇漏斗](/img/macdock/genie-minimize.jpg)

桌面组件可以摆在任意位置，那便签是真能打字、真能存盘的，不是装饰：

![桌面组件与可编辑 Dock](/img/macdock/widgets-dock-edit.jpg)

## 三种用起来的方式

### 一、装安装包（推荐）

去 [Releases](https://github.com/wanghcongcong-lulu/MacDock/releases/latest) 下 `MacDock-Setup-3.2.0-x64.exe`，1.85 MB，跑起来是个原生 Win32 安装向导，不是那种 Next-Next-Finish 的套壳安装器。它会自动检测旧版本、升级时保留配置，卸载走控制面板正常卸。

装完直接开，第一次启动会问你要不要隐藏原生任务栏——建议先留着，熟悉两天再关。

### 二、绿色便携版

不想装东西就用 `MacDock-v3.2.0-win64-portable.zip`，738 KB，解压双击，配置写在同目录，整个文件夹拷走就能换机器。U 盘里塞一份，到别人电脑上也能用。

### 三、自己编

环境要求：Windows 10/11 x64、VS2022（含"使用 C++ 的桌面开发"和 Windows SDK）、CMake 3.24+、Ninja。

```powershell
# 清干净重编 Release，产物在 dist\MacDock.exe
powershell -ExecutionPolicy Bypass -File .\build.ps1 -Clean

# 再打成安装包和便携包
powershell -ExecutionPolicy Bypass -File .\package_release.ps1 -Version 3.2.0 -Clean
```

编译过程没什么坑，CMake 一把过。唯一要注意的是静态 CRT 用了 `/MT`，别手动改成 `/MD`，改了就会带出一堆运行库依赖，1.5 MB 的优势就没了。

## 它凭什么这么小

拆开源码看目录，结构挺清楚：

- `src/core/` —— 配置持久化、弹簧物理引擎、热键、媒体与歌词匹配
- `src/ui/` —— Dock、菜单栏、控制中心、灵动岛、台前调度、Genie、组件、启动台
- `src/render/` —— Direct2D / D3D11 绘制与动画管线
- `src/shell/` —— 任务栏控制、托盘枚举、通知拦截、开机自启与无损还原
- `installer/` —— 原生 Win32 安装程序
- `website/` —— 官网与在线演示

不用 Electron、不用 WebView、不带 Chromium，界面全靠 D2D 自己画——这就是 1.48 MB 的来源。顺带的好处是高刷屏友好，60 / 120 / 144 / 240Hz 都能跟得上，动画不会一顿一顿。

## 快捷键

| 快捷键 | 功能 |
| --- | --- |
| `Alt + Space` | 启动台（中英文 / 拼音首字母搜索） |
| `Alt + Q` | Spotlight 聚焦搜索 + 实时计算器 |
| `Ctrl + Alt + ↑` | 调度中心 |
| `Ctrl + Alt + S` | 开关 3D 台前调度 |
| `Ctrl + Alt + C` | 控制中心 |
| `Ctrl + Alt + N` | 通知中心 |
| `Ctrl + Alt + T` | 临时显示 / 隐藏原生任务栏 |

都写在偏好设置里，能自己改。

## 几个需要注意的地方

- **系统门槛**：Windows 10 1903 及以上、Windows 11 x64。老一点的 LTSC 版本可能缺 `Windows.UI.Composition` 相关的组件，起不来别急着骂作者。
- **关掉原生任务栏之后**：万一手滑把 Dock 也关了，`Ctrl + Alt + T` 还能把原生任务栏喊回来，不至于卡死。
- **卸载**：走安装向导装的，控制面板正常卸；便携版直接删文件夹。项目号称"一键无损还原"，本质是所有改动都在运行时完成，不写系统主题文件——这点比那些改 shell 的方案稳妥得多。
- **杀软误报**：这种接管窗口、模拟按键、枚举托盘的软件，容易被某些安全软件标记为可疑行为。源码在，介意的话自己编一份。

## 说两句

这类"把 A 系统的审美搬到 B 系统"的工具，做得不好的时候就是一层塑料膜，看着像、用着别扭。MacDock 难得的是它把动画和物理手感做进去了——弹簧阻尼、VSync 漏斗、玻璃折射，这些都是要花时间打磨的细节，不是套个 CSS 模糊就完事。

1.48 MB、0% CPU、MIT 协议、源码全开，作者是"爱运动的Cc"。官网在 [macdock-win.pages.dev](https://macdock-win.pages.dev)，上面还有在线演示，懒得装也能先点两下试试手感。

> 本站所有项目都取自 GitHub 上的开源项目，仅用于个人学习使用，不作商业用途，版权归原作者所有。如有侵权，请留言告知，我会第一时间处理。
