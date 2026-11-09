import assert from 'node:assert/strict';
import { test } from 'node:test';

// The Edge Function uses only web standards and Deno's environment at import.
globalThis.Deno = { env: { get: () => undefined }, serve: () => {} };
const { handler } = await import('../supabase/functions/rss-proxy/index.ts');
const request = (url) => new Request(`https://project.example/rss-proxy?url=${encodeURIComponent(url)}`);

test('RSS proxy only fetches allowed HTTPS hosts, including redirects', async () => {
  const previous = globalThis.fetch;
  let calls = 0;
  try {
    globalThis.fetch = async () => { calls++; return new Response('<rss/>'); };
    for (const url of ['http://feeds.npr.org/feed', 'https://localhost/feed',
      'https://feeds.npr.org.evil.example/feed', 'https://user:pass@feeds.npr.org/feed',
      'https://feeds.npr.org:8443/feed']) {
      assert.equal((await handler(request(url))).status, 403);
    }
    assert.equal(calls, 0);
    const ok = await handler(request('https://feeds.npr.org/510289/podcast.xml'));
    assert.equal(ok.status, 200);
    assert.equal(ok.headers.get('Access-Control-Allow-Origin'), '*');
    assert.equal(await ok.text(), '<rss/>');
    for (const url of ['https://feeds.fireside.fm/sv101/rss',
      'https://sspai.typlog.io/feed/audio.xml',
      'https://feeds.rebuild.fm/rebuildfm',
      'https://feed.podbean.com/americanlife4989/feed.xml']) {
      assert.equal((await handler(request(url))).status, 200);
    }
    calls = 0;
    globalThis.fetch = async () => {
      calls++;
      return new Response(null, { status: 302, headers: { location: 'https://127.0.0.1/internal' } });
    };
    assert.equal((await handler(request('https://feeds.npr.org/feed'))).status, 403);
    assert.equal(calls, 1);
    globalThis.fetch = async () => new Response(new Uint8Array(5 * 1024 * 1024 + 1));
    assert.equal((await handler(request('https://feeds.npr.org/feed'))).status, 413);
    assert.equal((await handler(new Request('https://project.example/rss-proxy'))).status, 400);
    assert.equal((await handler(new Request('https://project.example/rss-proxy', { method: 'OPTIONS' }))).status, 200);
    assert.equal((await handler(new Request('https://project.example/rss-proxy', { method: 'POST' }))).status, 405);
  } finally { globalThis.fetch = previous; }
});
