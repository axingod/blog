---
title: Twikoo 评论系统白嫖部署：Cloudflare Workers + D1
date: 2026-11-25 22:10:00
categories:
  - 技术
tags:
  - Twikoo
  - Cloudflare
  - 建站
cover: https://panghu.langzixin.dpdns.org/img/cover/twikoo.jpg
description: 静态博客也能有评论区。用 Cloudflare 的免费额度跑 Twikoo，不花一分钱，留言直接写进数据库。
---

静态博客最大的尴尬是：文章写完了，没人能说话。

评论系统方案不少，Disqus 国外太慢，Waline 要服务器，Valine 依赖 LeanCloud（免费额度早就收紧）。最后选的是 **Twikoo**——它本身不挑后端，官方支持好几家云平台，其中 Cloudflare Workers + D1 这套是完全免费的。

## 整体结构

```text
浏览器（博客页面）
      ↓  POST 请求
Cloudflare Worker（跑 Twikoo 源码）
      ↓  读写
Cloudflare D1（SQLite 数据库，免费额度 5GB）
```

Worker 负责接口和鉴权，D1 存评论。没有额外服务，也就没有额外账单。

## 部署步骤

### 1. 拉起源码

```bash
git clone https://github.com/twikoojs/twikoo-cloudflare.git
cd twikoo-cloudflare
npm install
```

这个分支打包了体积不小的可选依赖（HTML 解析、腾讯云、邮件），部署前去 `node_modules` 里把用不上的大文件清掉，打包体积能从几 MB 降到 1 MB 左右，Worker 启动也更快。

### 2. 登录 wrangler

```bash
npx wrangler login
```

浏览器会弹授权页，点 Authorize 就行。授权范围里包含 D1 的读写权限，这一步很关键。

### 3. 建数据库

```bash
npx wrangler d1 create twikoo --location apac
```

`--location apac` 指定亚洲区，国内访问延迟会好一些。命令会返回一个 `database_id`，抄下来。

### 4. 写配置

`wrangler.toml` 里填上自己的 id：

```toml
name = "twikoo"
main = "src/index.js"
compatibility_flags = ["nodejs_compat"]

[[d1_databases]]
binding = "DB"
database_name = "twikoo"
database_id = "你刚才拿到的 id"
```

### 5. 建表

```bash
npx wrangler d1 execute twikoo --file=./schema.sql --remote
```

别漏 `--remote`，不然只写了本地测试库。

### 6. 部署

```bash
npx wrangler deploy --minify
```

成功后终端会打印一个 `https://xxx.workers.dev` 地址，这就是评论接口。

### 7. 接入博客

主题配置里填上刚拿到的地址：

```yaml
comments:
  use: Twikoo

twikoo:
  envId: https://xxx.workers.dev
```

重新生成站点，文章页底部就会出现评论框。

## 几个注意点

**workers.dev 域名的连通性。** 这个域名在国内部分网络会被解析到不可用地址。如果访客打不开评论区，可以绑定自己的域名（Cloudflare 里自定义域即可）。

**第一个管理员。** 用站长的邮箱发一条评论，进评论框右下角的设置图标，就能设置管理密码——之后删评论、导出数据都在那个面板里。

**图片上传是可选功能。** Twikoo 支持评论带图，但需要额外开 R2 存储。没开也不影响文字评论，只是上传按钮会不可用。

## 验证

部署完先测接口：

```bash
curl -X POST https://xxx.workers.dev \
  -H "Content-Type: application/json" \
  -d '{"event":"GET_CONFIG"}'
```

返回一段带版本号的 JSON，说明 Worker 通了。再去文章页发一条，刷新后能看到，说明数据库也通了。

整个流程走下来大概二十分钟，除了 Cloudflare 账号，什么都不用买。
