"""Package *public app files only* for offline launch after the first install.

Run after `flutter build web --release --no-web-resources-cdn`. A new shell
waits for old clients to close; business data never enters the Cache Storage API.
"""

from hashlib import sha256
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1] / 'build' / 'web'
REGISTRATION = '''<script>
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register(new URL('strata-sw.js', document.baseURI),
        {updateViaCache: 'none'}).catch(error => console.warn('Offline shell:', error.name));
    }
  </script>'''


def main():
    for required in ('main.dart.js', 'sqlite/sqlite3.wasm', 'sqlite/drift_worker.js', 'canvaskit/canvaskit.wasm'):
        if not (ROOT / required).is_file():
            raise SystemExit(f'Missing {required}; build a self-contained web release first.')
    index = ROOT / 'index.html'
    html = index.read_text(encoding='utf-8')
    if REGISTRATION not in html:
        index.write_text(html.replace('</body>', REGISTRATION + '\n</body>'), encoding='utf-8')
    resources = []
    digest = sha256()
    for path in sorted(ROOT.rglob('*')):
        if (not path.is_file() or path.name in ('strata-sw.js', 'flutter_service_worker.js')
                or path.name.startswith('.') or path.suffix in ('.map', '.symbols')):
            continue
        url = path.relative_to(ROOT).as_posix()
        resources.append(url)
        digest.update(url.encode() + b'\0' + sha256(path.read_bytes()).digest())
    worker = ''''use strict';
const scope = self.registration.scope;
const prefix = 'strata-app-shell:' + scope + ':';
const cacheName = prefix + REVISION;
const files = new Set(FILES.map(path => new URL(path, scope).href));
self.addEventListener('install', event => {
  event.waitUntil(caches.open(cacheName).then(cache => cache.addAll(
    [...files].map(url => new Request(url, {cache: 'reload'})))));
});
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    for (const key of await caches.keys()) {
      if (key.startsWith(prefix) && key !== cacheName) await caches.delete(key);
    }
    await self.clients.claim();
  })());
});
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  url.search = ''; url.hash = '';
  const key = url.href === scope ? new URL('index.html', scope).href : url.href;
  if (files.has(key)) event.respondWith(caches.open(cacheName)
    .then(async cache => (await cache.match(key)) || fetch(event.request)));
});
'''
    script = worker.replace('REVISION', json.dumps(digest.hexdigest())).replace('FILES', json.dumps(resources))
    (ROOT / 'strata-sw.js').write_text(script, encoding='utf-8')
    print(f'Prepared offline shell: {len(resources)} static files, revision {digest.hexdigest()[:12]}')


if __name__ == '__main__':
    main()
