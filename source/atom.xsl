<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:atom="http://www.w3.org/2005/Atom"
  exclude-result-prefixes="atom">
  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <html lang="zh-CN">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width,initial-scale=1" />
        <title><xsl:value-of select="atom:feed/atom:title" /> · RSS 订阅</title>
        <style>
          *{box-sizing:border-box}
          body{margin:0;padding:36px 16px;background:#f4f6fa;color:#2b333f;
               font-family:-apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC","Microsoft YaHei",sans-serif;
               -webkit-font-smoothing:antialiased}
          .card{max-width:760px;margin:0 auto;background:#fff;border-radius:18px;padding:30px 30px 22px;
                box-shadow:0 8px 28px rgba(31,45,70,.07)}
          header{display:flex;align-items:center;gap:16px}
          .avatar{width:62px;height:62px;border-radius:50%;object-fit:cover;flex:0 0 auto;
                  box-shadow:0 3px 10px rgba(31,45,70,.14)}
          h1{font-size:19px;margin:0;line-height:1.4}
          .sub{margin:5px 0 0;font-size:12.5px;color:#8b95a3}
          .hint{margin-top:20px;padding:12px 14px;border-radius:11px;background:#f1f5ff;
                font-size:12.5px;color:#4c5a70;line-height:1.9}
          code{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;font-size:12px;
               background:#e3eaff;color:#2b46c9;padding:3px 7px;border-radius:6px;word-break:break-all}
          .feedline{display:flex;align-items:center;flex-wrap:wrap;gap:8px;margin-top:9px}
          .feedline code{flex:1 1 auto;min-width:0}
          .copy{margin-left:8px;border:none;background:#425AEF;color:#fff;font-size:12px;padding:5px 11px;
                border-radius:7px;cursor:pointer;vertical-align:middle}
          .copy:hover{background:#3349cc}
          .list{list-style:none;margin:26px 0 0;padding:0}
          .item{padding:19px 0;border-top:1px solid #edf0f5}
          .item:first-child{border-top:none;padding-top:6px}
          .date{font-size:11.5px;color:#a3adba;letter-spacing:.5px}
          a.title{display:block;margin:7px 0 0;font-size:16px;font-weight:600;color:#1d2531;text-decoration:none}
          a.title:hover{color:#425AEF}
          .sum{margin:7px 0 0;font-size:13px;line-height:1.75;color:#6d7887}
          .chips{margin-top:9px}
          .chip{display:inline-block;margin:0 6px 4px 0;padding:2px 8px;border-radius:999px;
                font-size:11px;color:#425AEF;background:#eef2ff}
          footer{margin-top:24px;padding-top:16px;border-top:1px solid #edf0f5;
                 font-size:12px;color:#a3adba;text-align:center;line-height:1.9}
          footer a{color:#425AEF;text-decoration:none}
          @media (max-width:520px){body{padding:18px 12px}.card{padding:20px 18px;border-radius:14px}
            .avatar{width:52px;height:52px}h1{font-size:17px}}
          @media (prefers-color-scheme:dark){
            body{background:#0e1116;color:#d5dae2}
            .card{background:#171b22;box-shadow:none}
            a.title{color:#e6eaf0}a.title:hover{color:#8fa8ff}
            .item{border-color:#232936}footer{border-color:#232936}
            .sub,.date,footer{color:#6f7a89}
            .hint{background:#1b2434;color:#9aacc6}
            code{background:#222c40;color:#a9bcff}
            .sum{color:#8d97a6}
            .chip{background:#1d2640;color:#95abff}
          }
        </style>
      </head>
      <body>
        <div class="card">
          <header>
            <img class="avatar" src="https://panghu.langzixin.dpdns.org/img/avatar.jpg" alt="" />
            <div>
              <h1><xsl:value-of select="atom:feed/atom:title" /></h1>
              <p class="sub">
                RSS 订阅源 · 共 <xsl:value-of select="count(atom:feed/atom:entry)" /> 篇文章 ·
                最近更新 <xsl:value-of select="substring(atom:feed/atom:updated,1,10)" />
              </p>
            </div>
          </header>

          <div class="hint">
            这是给 RSS 阅读器用的订阅地址，把下面这条链接添加到 Feedly、Inoreader、Reeder 等阅读器即可订阅：
            <div class="feedline">
              <code id="feedUrl">https://panghu.langzixin.dpdns.org/atom.xml</code>
              <button class="copy" id="copyBtn" type="button">复制</button>
            </div>
          </div>

          <ul class="list">
            <xsl:for-each select="atom:feed/atom:entry">
              <li class="item">
                <div class="date">
                  <xsl:choose>
                    <xsl:when test="atom:published">
                      <xsl:value-of select="substring(atom:published,1,10)" />
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="substring(atom:updated,1,10)" /></xsl:otherwise>
                  </xsl:choose>
                </div>
                <a class="title" href="{atom:link/@href}">
                  <xsl:value-of select="atom:title" />
                </a>
                <p class="sum"><xsl:value-of select="atom:summary" /></p>
                <div class="chips">
                  <xsl:for-each select="atom:category">
                    <span class="chip"><xsl:value-of select="@term" /></span>
                  </xsl:for-each>
                </div>
              </li>
            </xsl:for-each>
          </ul>

          <footer>
            原文地址：<a href="{atom:feed/atom:link[@rel='alternate']/@href}"><xsl:value-of select="atom:feed/atom:link[@rel='alternate']/@href" /></a>
            <br />订阅源由 <a href="https://hexo.io">Hexo</a> 生成 · 用阅读器订阅体验更好
          </footer>
        </div>

        <script type="text/javascript">
          (function () {
            var url = location.href;
            var code = document.getElementById('feedUrl');
            var btn = document.getElementById('copyBtn');
            if (code) code.textContent = url;
            if (btn) {
              btn.addEventListener('click', function () {
                var done = function () { btn.textContent = '已复制'; setTimeout(function () { btn.textContent = '复制'; }, 1600); };
                if (navigator.clipboard &amp;&amp; navigator.clipboard.writeText) {
                  navigator.clipboard.writeText(url).then(done, function () { fallback(); });
                } else { fallback(); }
                function fallback() {
                  var t = document.createElement('textarea');
                  t.value = url; document.body.appendChild(t); t.select();
                  try { document.execCommand('copy'); done(); } catch (e) {}
                  document.body.removeChild(t);
                }
              });
            }
            var sums = document.querySelectorAll('.sum');
            for (var i = 0; i &lt; sums.length; i++) {
              var raw = sums[i].textContent || '';
              var text = '';
              try {
                var doc = new DOMParser().parseFromString(raw, 'text/html');
                text = (doc.body ? doc.body.textContent : '') || '';
              } catch (e) { text = raw; }
              text = text.replace(/\s+/g, ' ').trim();
              if (text.length > 115) text = text.slice(0, 115) + '…';
              if (text) { sums[i].textContent = text; } else { sums[i].style.display = 'none'; }
            }
          })();
        </script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
