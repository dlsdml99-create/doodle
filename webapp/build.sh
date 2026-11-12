#!/usr/bin/env bash
# 아이폰·태블릿용 웹앱을 site/app/ 에 만들어요 (다운로드 페이지와 같이 올라감)
set -e
V="${1:-dev}"
mkdir -p site/app/fonts
cp index.html icon-180.png icon-512.png site/app/
# 글꼴: 빌드 때 만든 woff2(더 작음)를 먼저 씀. woff는 woff2를 못 읽는 예전 브라우저만 받음
cp fonts/*.woff site/app/fonts/
if ls fonts/*.woff2 >/dev/null 2>&1; then cp fonts/*.woff2 site/app/fonts/; FX=woff2; else FX=woff; fi
cp fonts/OFL-*.txt site/app/fonts/
cp webapp/manifest.webmanifest site/app/
sed "s/__V__/$V/; s/\.woff'/.$FX'/g" webapp/sw.js > site/app/sw.js
python3 - <<'PY'
p='site/app/index.html'; s=open(p,encoding='utf-8').read()
head=('<link rel="manifest" href="manifest.webmanifest">\n<meta name="apple-mobile-web-app-capable" content="yes">\n'
      '<meta name="mobile-web-app-capable" content="yes">\n<meta name="apple-mobile-web-app-status-bar-style" content="default">\n'
      '<meta name="apple-mobile-web-app-title" content="Doodle">\n')
a='<link rel="apple-touch-icon" href="icon-180.png">'
assert s.count(a)==1; s=s.replace(a,a+'\n'+head)
s+="\n<script>if('serviceWorker' in navigator)addEventListener('load',()=>navigator.serviceWorker.register('sw.js').catch(()=>{}));</script>\n"
open(p,'w',encoding='utf-8').write(s)
PY
echo "webapp ok ($V, $FX)"
