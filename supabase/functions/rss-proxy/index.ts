// Public read-only RSS proxy for Flutter Web. No Supabase secret is needed.
// Only explicitly approved feed hosts can be fetched, including redirects.
const headers = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "apikey, authorization, content-type, x-client-info",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Content-Type": "application/xml; charset=utf-8",
  "Cache-Control": "public, max-age=600",
};
const allowedHosts = new Set(
  (Deno.env.get("RSS_ALLOWED_HOSTS") ?? "feeds.npr.org,feeds.simplecast.com,feeds.fireside.fm,sspai.typlog.io,feeds.rebuild.fm,feed.podbean.com")
    .split(",").map((host) => host.trim().toLowerCase()).filter(Boolean),
);
function approved(url: URL) {
  return url.protocol === "https:" && !url.username && !url.password &&
    (!url.port || url.port === "443") && allowedHosts.has(url.hostname);
}
function error(message: string, status: number) {
  return new Response(message, { status, headers: {
    ...headers, "Content-Type": "text/plain; charset=utf-8", "Cache-Control": "no-store",
  } });
}
export async function handler(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") return new Response(null, { headers });
  if (request.method !== "GET") return error("Method not allowed", 405);
  const input = new URL(request.url).searchParams.get("url");
  if (!input) return error("Missing feed URL", 400);
  let target: URL;
  try { target = new URL(input); } catch { return error("Invalid URL", 400); }
  try {
    for (let attempt = 0; attempt < 4; attempt++) {
      if (!approved(target)) return error("Feed host is not approved. Configure RSS_ALLOWED_HOSTS.", 403);
      const upstream = await fetch(target, {
        redirect: "manual", signal: AbortSignal.timeout(12_000),
        headers: { "Accept": "application/rss+xml,application/xml,text/xml", "User-Agent": "MusicPod/1.0 RSS Reader" },
      });
      if (upstream.status >= 300 && upstream.status < 400) {
        const location = upstream.headers.get("location");
        await upstream.body?.cancel();
        if (!location) return error("Feed redirect is invalid", 502);
        target = new URL(location, target);
        continue;
      }
      if (!upstream.ok || !upstream.body) {
        await upstream.body?.cancel();
        return error("Feed publisher is unavailable", 502);
      }
      const reader = upstream.body.getReader();
      const chunks: Uint8Array[] = [];
      let size = 0;
      while (true) {
        const { value, done } = await reader.read();
        if (done) break;
        size += value.byteLength;
        if (size > 5 * 1024 * 1024) {
          await reader.cancel(); return error("Feed exceeds 5 MB", 413);
        }
        chunks.push(value);
      }
      const data = new Uint8Array(size);
      let offset = 0;
      for (const chunk of chunks) { data.set(chunk, offset); offset += chunk.length; }
      return new Response(data, { headers });
    }
    return error("Too many feed redirects", 502);
  } catch {
    return error("Could not fetch feed", 502);
  }
}
Deno.serve(handler);
