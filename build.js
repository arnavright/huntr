const fs = require('fs');
const path = require('path');

// Load .env if present (local dev)
try {
  const envFile = fs.readFileSync(path.join(__dirname, '.env'), 'utf8');
  for (const line of envFile.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eqIdx = trimmed.indexOf('=');
    if (eqIdx === -1) continue;
    const key = trimmed.slice(0, eqIdx).trim();
    const val = trimmed.slice(eqIdx + 1).trim().replace(/^['"]|['"]$/g, '');
    if (!process.env[key]) process.env[key] = val;
  }
} catch (_) {
  // no .env file — rely on environment variables (e.g. Vercel)
}

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;

if (!url || !anonKey) {
  console.error('Error: SUPABASE_URL and SUPABASE_ANON_KEY must be set.');
  process.exit(1);
}

const indexPath = path.join(__dirname, 'index.html');
let html = fs.readFileSync(indexPath, 'utf8');

html = html.replace(/__SUPABASE_URL__/g, url);
html = html.replace(/__SUPABASE_ANON_KEY__/g, anonKey);

fs.writeFileSync(indexPath, html);
console.log('Build complete — credentials injected into index.html');
