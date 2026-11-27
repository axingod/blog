---
title: 你好，世界：这个博客开张了
date: 2026-11-27 20:15:50
categories:
  - 随笔
tags:
  - Hexo
  - 建站
cover: https://panghu.langzixin.dpdns.org/img/cover/hello-world-v5.jpg
description: 折腾了一晚上，这个博客终于上线了。这是第一篇，留个位置。
---

折腾了一整个晚上，这个博客终于上线了。

域名没有，服务器没有，预算也没有，所以最后用的是最"白嫖"的组合：**Hexo 生成静态页 + GitHub Pages 托管**，代码往仓库一推，几分钟后网页就活了。

## 这里会写点什么

- 折腾记录：把踩过的坑写下来，下次自己少走一遍，别人路过也能少走一遍。
- 技术笔记：前端、脚本、工具链，想到哪写到哪。
- 生活随笔：偶尔也写点不像代码的东西。

## 本站是怎么搭的

```bash
# 大致就是这么几步
hexo init blog
npm install
hexo generate
git push   # GitHub Actions 自动构建并发布
```

主题用的是 [AnzhiYu](https://github.com/anzhiyu-c/hexo-theme-anzhiyu)，配色、目录、相关推荐都是现成的，省了不少功夫。

评论区用的是 Twikoo，跑在 Cloudflare Workers 上，数据存在 D1，不需要另买服务器。想留言的话，文章底部就能直接说。

## 最后

第一篇总是最难写的，写着写着就成了自我介绍。

那就先这样——你好，世界。
