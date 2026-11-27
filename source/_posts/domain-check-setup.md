---
title: 给域名装个到期监控：Worker + KV 免费方案
date: 2026-11-28 12:00:00
categories:
  - 实用项目
tags:
  - Cloudflare
  - 域名
  - 工具
cover: https://panghu.langzixin.dpdns.org/img/cover/domain-check-v9.jpg
description: 域名一多，续费全靠自觉。这份教程把 domain-check 这套 Worker + KV 的到期监控台，从 Fork 一路部署到 Telegram 提醒，全程不用一台服务器。
---

域名这东西，续费全靠自觉。

买三五个的时候还记得，买到十个八个，就变成"某天突然收到一封『您的域名将在 3 天后过期』的邮件"，然后手忙脚乱找注册商登录。

所以我把 [yutian81/domain-check](https://github.com/yutian81/domain-check) 这套东西完整走了一遍：一个跑在 Cloudflare Worker 上的域名到期监控台，KV 存数据，定时查 WHOIS，快到期了往 Telegram 推消息。本文是它的部署教程。

## 它到底解决什么问题

一句话：**把"这个域名什么时候到期"从脑子里搬到一块随时能看的看板上**。

它不买域名、不续费、不改 DNS，只做三件事：

1. 记录你有哪些域名、在哪注册、什么时候到期
2. 每天定时跑一遍，算出还剩几天
3. 快到期了（默认 30 天内）往 Telegram 发提醒

一级域名连到期日期都不用你填——添加时它自己去查 WHOIS，把注册商、注册日期、到期日期、DNS 服务器一起抓回来。

## 能力清单

| 能力 | 说明 |
| --- | --- |
| 双模式 | `/` 公开页只读且脱敏，`/admin` 管理页要密码 |
| 域名管理 | 增删改查、克隆、批量勾选删除 |
| WHOIS 自动填充 | 一级域名自动查，主源 ip.sb，失败回退 RDAP |
| 分组 | 域名按彩色标签分组，方便区分项目 |
| 续期记录 | 卡片上有续期按钮，按年/月续，自动推算新到期日 |
| 备份 | 支持导出/导入 JSON |
| 到期提醒 | Cron 定时检查 + Telegram 推送 |
| 手动触发 | 浏览器打开 `/cron` 就能立刻跑一次检查 |

公开页挺有意思：域名会被脱敏成 `*****.com`，注册账号直接变成 `***********`，而且这份脱敏是**服务端渲染好直接塞进 HTML 的**，前端根本不调 API。也就是说，你可以放心把首页发给别人看，别人也拿不到你具体的域名。

## 为什么是 Worker + KV

因为这套需求太适合边缘计算了：

- 没有常驻进程需求，一天跑两次定时任务
- 数据量极小，十几个域名加起来几 KB
- 要一直在线，但不能为它养一台 VPS

Cloudflare 免费额度是每天 10 万次 Worker 请求、KV 每天 10 万次读 / 1000 次写。这个项目一天最多几次读写，免费额度基本用不完。

## 部署前准备

需要三样东西：

1. 一个 Cloudflare 账号（免费即可）
2. 一个 GitHub 账号，用来 Fork 仓库跑 Action
3. 一个 Telegram Bot（可选，不配就没有推送）

**关键一步是 API Token 的权限**。去 Cloudflare 后台 `My Profile → API Tokens → Create Token`，用自定义模板，勾上这两项：

- `Account` → `Workers Scripts` → `Edit`
- `Account` → `Workers KV Storage` → `Edit`

顺手把 `Account ID` 记下来（Workers & Pages 概览页右侧就有），后面要用。

## 第一步：Fork 仓库

打开 [github.com/yutian81/domain-check](https://github.com/yutian81/domain-check)，点 Fork。

> 为什么不直接在 Cloudflare 后台"连接 Git 仓库"部署？因为这个项目的 KV 绑定和 Cron 触发器全靠 `wrangler.toml` 里的占位符在构建时替换。用 CF 网页那套连接方式，重新部署时这些配置会丢。用 GitHub Action 跑 wrangler，配置才是持久的。

## 第二步：建一个 KV 空间

Cloudflare 后台 → `Storage & Databases` → `KV` → `Create namespace`，名字随意，比如 `DOMAIN_KV`。

创建完，KV 列表里名字右边那串字符就是 **KV ID**，复制备用。

## 第三步：填 Secrets

进你 Fork 出来的仓库 → `Settings` → `Secrets and variables` → `Actions` → `Secrets` 标签页，依次添加：

| 名称 | 必填 | 内容 |
| --- | --- | --- |
| `CF_API_TOKEN` | 是 | 上一步创建的 API Token |
| `CF_KV_ID` | 是 | 刚复制的 KV ID |
| `PASSWORD` | 是 | 管理页密码，不填默认 `123123`（强烈建议改） |
| `TGID` | 否 | Telegram chat id |
| `TGTOKEN` | 否 | Telegram Bot token |

## 第四步：填 Variables

切到同一页的 `Variables` 标签页：

| 名称 | 必填 | 内容 |
| --- | --- | --- |
| `CF_ACCOUNT_ID` | 是 | Cloudflare 账户 ID（是 ID，不是邮箱） |
| `CF_CRONS` | 否 | Cron 表达式，不填默认 `0 1,13 * * *` |

{% raw %}

```bash
# CF_CRONS 默认值含义（UTC 时间）：
# 0 1,13 * * *  →  每天 UTC 1:00 和 13:00
# 换算成北京时间就是 9:00 和 21:00
```

{% endraw %}

## 第五步：跑 Action

仓库 → `Actions` → 左侧选「自动部署到 CF Worker」→ 右侧 `Run workflow` → 分支选 `main` → 运行。

等它跑完，日志最后会打印一个链接：

```
https://dash.cloudflare.com/<你的账户ID>/workers/services/view/domain-check/production/settings
```

点进去就是 Worker 的管理页。Action 顺便把 `wrangler.toml` 里的 `{CF_KV_ID}`、`{CF_CRONS}` 换成真实值再部署，所以 KV 绑定和定时器都是带着走的。

## 第六步：绑域名（可选但建议）

Worker 默认给你一个 `xxx.workers.dev` 的地址，能用但不好记。在 Worker 详情页 → `Settings` → `Domains & Routes` → `Add custom domain`，填一个你账号下已有的域名（比如 `check.example.com`）即可。

同一个页面往下还有 `Variables and Secrets`，可以补这些可选配置：

| 变量 | 作用 | 默认 |
| --- | --- | --- |
| `SITENAME` | 站点标题 | 域名到期监控 |
| `ICON` | 站点图标 | 项目自带图标 |
| `BGIMG` | 登录页/看板背景图 | 项目自带图 |
| `DAYS` | 提前多少天提醒 | 30 |
| `GITHUB_URL` | 页脚 GitHub 链接 | 项目地址 |
| `BLOG_URL` | 页脚博客链接 | 作者博客 |
| `BLOG_NAME` | 页脚博客名 | QingYun Blog |

改完变量记得点保存，Worker 会立刻生效，不用重新部署。

## 用起来是什么样

打开 `https://你的域名/` 是公开页：域名全部脱敏，没有操作按钮，右上角一个「登录」。点进去输入密码，跳转 `/admin`，这才是完整的管理界面。

添加域名时，如果填的是一级域名（`example.com` 这种两段式），到期日期留空就行，保存时它会去查 WHOIS 自动补全注册商、注册日期、到期日期。二级域名（`blog.example.com`）查不到 WHOIS，需要手动填注册日期、到期日期、注册商和注册商官网。

管理页里还有几个顺手的功能：

- 卡片右上角复选框，能多选批量删
- 「克隆」会拿这张卡的注册商信息预填到添加表单，域名留空，加同一家注册商的域名时省事
- 「续期」按年或按月续，自动把到期日往后推并记一笔续费周期
- 右上角「导出」把所有域名存成 JSON，换机器或者误删了能导回来

## 让 Telegram 帮你盯

不加 TG 也能用，但要它主动提醒你，就得配 Bot：

1. Telegram 里找 `@BotFather`，发 `/newbot`，按提示起名字，拿到一串 `123456:ABC-DEF...` 的 token
2. 给你的 bot 发一条任意消息（必须你先发，否则它没法给你推）
3. 浏览器打开 `https://api.telegram.org/bot<你的token>/getUpdates`，找到 `"chat":{"id":xxxxxxx}`，这串数字就是 chat id
4. 把 token 和 chat id 分别填进仓库的 `TGTOKEN`、`TGID`，重跑一次 Action 让环境变量生效

推送长这样：

```
🚨 域名到期提醒 🚨
🌐 域名: example.com
♻️ 将在 12天 后过期！
📅 过期日期: 2027-01-09
🔗 注册商: ...
```

提醒的触发条件是「剩余天数大于 0 且不超过 `DAYS`」，也就是说到期当天之后就不再推了——如果真过期了它不会继续提醒，这点要心里有数。

## 定时任务别把 UTC 当北京时间

`CF_CRONS` 用的是标准 Cron 表达式，Cloudflare 按 **UTC** 解释。默认 `0 1,13 * * *` 正好对应北京时间 9 点和 21 点。想改成每天早上 8 点提醒，得写 `0 0 * * *`（UTC 0 点 = 北京 8 点）。

改完要重新跑 Action，因为 cron 是在 `wrangler.toml` 里替换进去的。

想立刻验证一次推送有没有配通？浏览器直接访问 `https://你的域名/cron`，它会把即将到期的域名列表以 JSON 返回，同时按配置发 TG。

## 数据到底存在哪

KV 里每个域名一个独立 key：

```
domain:example.com      → {"domain":"example.com","expirationDate":"2027-01-09", ...}
domain:another.net      → {...}
```

不用一个大数组，好处是增删改都是单 key 原子操作，不会出现两个人同时操作把列表写坏的情况。

老版本用的是单个 `DOMAIN_LIST` key，如果你是从旧版升上来的，第一次访问时会自动把旧数据拆成新格式再删掉旧 key，不用手动迁移。

## 想改代码、本地跑

```bash
git clone https://github.com/yutian81/domain-check.git
cd domain-check
npm install
npx wrangler dev          # 本地起 Worker，默认 http://localhost:8787
```

前端是模块化拼起来的，源码在 `frontend/src/` 下按序号分文件（配置、工具函数、API、UI、表单、筛选、初始化），改完要重新打包：

```bash
node frontend/build.js    # 生成 frontend/script.js
```

`frontend/script.js` 是构建产物，别直接改，下次构建会被覆盖。

本地调试时需要本地 KV，`wrangler dev` 会自动起一个内存版 KV，重启即清空，正好用来乱试。

## 几个容易踩的点

**wrangler.toml 别用网页连接方式部署。** 前面说过，`{CF_KV_ID}` 这种占位符要靠 Action 的 `sed` 替换，网页连接方式不认这套，重新部署会丢 KV 绑定和定时器。

**密码别留默认值。** 默认 `123123` 是公开的秘密，管理页能改能删，被人摸到就等于数据全公开。改成自己的，改完重跑 Action。

**登录 Cookie 有效期 7 天。** 鉴权就是把密码写进 `auth` Cookie 里比对，HttpOnly + Secure + SameSite=Lax。点「退出」会清掉 Cookie，下次要重新输密码。

**二级域名不会自动查。** 只有两段式的一级域名会走 WHOIS，`a.b.com` 这种得手填，别以为是坏了。

**RDAP 回退的数据可能不全。** 主源 ip.sb 拿不到 `Registry Expiry Date` 时才会退到 RDAP，而 RDAP 各注册局返回的字段并不统一，偶尔注册商名字会变成一串 handle。看到奇怪的值手动改一下就行。

**公开页脱敏是服务端做的。** 域名只留后缀，账号全打码。但如果你连后缀都不想暴露，就别把 `/` 这个地址公开出去 —— 它默认是公开的。

## 成本

全部在 Cloudflare 免费额度内：Worker 每天 10 万请求、KV 每天 10 万读 + 1000 写。一个几十个域名的监控台，一天撑死几十次读写，一年也碰不到边。

GitHub Actions 免费额度也够，只在 push 到 `src/`、`frontend/` 或 `wrangler.toml` 时触发。

## 最后

项目地址：[github.com/yutian81/domain-check](https://github.com/yutian81/domain-check)，MIT 协议，作者 [yutian81](https://github.com/yutian81)。感谢作者把这套东西开源出来。

如果你也有一堆域名，又不想再靠"想起来"来续费，花二十分钟按上面走一遍，之后每年能省下的不止是钱，还有那种"好像有什么要到期了"的隐隐不安。
