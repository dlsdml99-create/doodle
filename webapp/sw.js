// Doodle 웹앱: 한 번 열면 인터넷 없이도 쓸 수 있게 저장하고, 인터넷이 되면 항상 새 버전을 먼저 받아요.
// 이 사이트(github.io/doodle/app/) 파일만 다루고, 다른 곳으로는 아무것도 보내지 않아요.
// 같은 github.io 주소의 다른 앱 캐시는 건드리지 않아요: 지울 때도 doodle- 로 시작하는 것만 지워요.
const CACHE = 'doodle-__V__';
const FILES = ['./', './index.html', './manifest.webmanifest', './icon-180.png', './icon-512.png',
  './fonts/gaegu-700.woff', './fonts/gowun-400.woff'];
self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k.startsWith('doodle-') && k !== CACHE).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const u = new URL(e.request.url);
  if (e.request.method !== 'GET' || u.origin !== location.origin || !u.pathname.startsWith(new URL('./', location).pathname)) return;
  e.respondWith(fetch(e.request).then(r => {
    if (r.ok) { const cp = r.clone(); caches.open(CACHE).then(c => c.put(e.request, cp)); }
    return r;
  }).catch(() => caches.match(e.request, { ignoreSearch: true }).then(r => r || caches.match('./index.html'))));
});
