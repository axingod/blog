---
title: Hexo 博客从零搭建实录：Windows + AnzhiYu + GitHub Pages
date: 2026-11-26 21:30:00
categories:
  - 技术
tags:
  - Hexo
  - 建站
  - GitHub Pages
cover: https://panghu.langzixin.dpdns.org/img/cover/hexo-setup-v4.jpg
description: 一台 Windows 电脑、一个 GitHub 账号，零成本把博客搭起来并推到线上，顺手记录几个真踩过的坑。
---

一台 Windows 电脑、一个 GitHub 账号、一个晚上，博客就上线了。整个过程不需要服务器，也不需要备案。

## 一、环境准备

需要两样东西：

1. **Node.js**（建议 LTS 以上）
2. **Git**（用来把代码推到 GitHub）

装完记得检查环境变量。我这次就栽在这里——`git` 和 `node` 明明装好了，命令行却一直提示"不是内部或外部命令"，查了半天发现是安装时没把路径写进 `Path`，手动补上再重开终端才正常。

```powershell
node -v
npm -v
git --version
```

三个都有版本号输出，才算真的装好了。

## 二、初始化博客

```bash
npm install -g hexo-cli
hexo init blog
cd blog
npm install
```

`hexo init` 有时候会因为网络中断，但目录骨架其实已经生成好了，这时候直接 `npm install` 补齐依赖就能继续，不用删了重来。

本地预览：

```bash
hexo server
# 打开 http://localhost:4000
```

## 三、换成 AnzhiYu 主题

默认主题太素，换成 [AnzhiYu](https://github.com/anzhiyu-c/hexo-theme-anzhiyu)。

```bash
npm install hexo-theme-anzhiyu
```

然后在 `_config.yml` 里指定主题：

```yaml
theme: anzhiyu
```

主题的配置文件一般是 `_config.anzhiyu.yml`，复制一份到根目录就能正常读取。封面、头像、菜单、侧边卡片都在这里面改。

## 四、推到 GitHub Pages

### 1. 建仓库

GitHub 上新建一个公开仓库，比如 `blog`。

### 2. 用 Actions 自动构建

这种方式不需要把编译后的 `public` 目录提交上去，源码推上去，GitHub 自己跑 `hexo generate` 再发布。

在仓库里加 `.github/workflows/pages.yml`，用官方的 Pages 发布流程；然后在仓库 Settings → Pages 里，把发布源选成 **GitHub Actions**。

### 3. 推送

```bash
git add .
git commit -m "init blog"
git push origin main
```

## 五、我踩的几个坑

**SSH 推送不通。** 密钥加上了、`ssh -T` 偶尔能过，但 `git push` 反复 `Permission denied (publickey)`，换 443 端口也卡住。最后放弃 SSH，改用 HTTPS + Personal Access Token：

```bash
git config --global credential.helper store
# 首次 push 时用户名填 GitHub 用户名，密码填 token
```

Token 在 GitHub 的 Settings → Developer settings → Personal access tokens 里生成，记得勾上 `repo` 权限。

**路径前缀。** 如果仓库名叫 `blog`，站点地址就是 `https://用户名.github.io/blog/`，那 `_config.yml` 里必须同时改两处，否则 CSS 和图片会全部 404：

```yaml
url: https://用户名.github.io/blog
root: /blog/
```

**首页大图。** 主题默认的 banner 是外链，偶尔加载慢，换成自己图床或本地图片更稳：

```yaml
index_img: "background: url(/blog/img/banner.jpg) top center / cover no-repeat"
```

## 六、写在最后

这套方案最大的好处是：**不用管服务器**。写完文章 `git push`，剩下的交给 GitHub。代价是只能做静态站，评论、统计这类需要后端的功能得另外接（我用的是 Twikoo，另一篇里写了）。

搭博客这件事，最花时间的往往不是技术，而是"要不要开始"。开始了，剩下的都能搜到答案。
