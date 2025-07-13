self.addEventListener('install', e => {
    e.waitUntil(
      caches.open('dair-site-v1').then(cache => {
        return cache.addAll([
          '/',
          '/card.html',
          '/imge/icon1.png',
          '/manifest.json',
          '/audio/click.mp3'
        ]);
      })
    );
  });
  
  self.addEventListener('fetch', e => {
    e.respondWith(
      caches.match(e.request).then(response => response || fetch(e.request))
    );
  });
  