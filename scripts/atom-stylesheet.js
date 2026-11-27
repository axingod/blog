'use strict';

const fs = require('fs');
const path = require('path');

const PI = '<?xml-stylesheet type="text/xsl" href="/atom.xsl"?>';

// 在进程退出前（文件已全部落盘）给 atom.xml 挂上 XSLT 样式表，
// 让浏览器直接打开时显示成文章列表页，RSS 阅读器不受影响。
hexo.extend.filter.register('before_exit', function () {
  const file = path.join(hexo.base_dir, 'public', 'atom.xml');
  if (!fs.existsSync(file)) return;

  let content = fs.readFileSync(file, 'utf8');
  if (content.indexOf('xml-stylesheet') !== -1) return;

  content = content.replace(/\uFEFF?<\?xml[^>]*\?>\s*/, function (match) {
    return match.replace(/\s+$/, '') + '\n' + PI + '\n';
  });

  fs.writeFileSync(file, content, 'utf8');
});
