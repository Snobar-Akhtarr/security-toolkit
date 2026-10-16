// Read the key from the .env file
process.loadEnvFile('.env');

const express = require('express');
const app = express();

// Parse JSON bodies of POST requests
app.use(express.json());

const PORT = 3000;
const VT_API_KEY = process.env.VT_API_KEY;
const VT_BASE = 'https://www.virustotal.com/api/v3';

app.get('/hello', (req, res) => {
  res.json({ message: 'Hello Snobar!' });
});

// Test only: tells whether the key was loaded (never returns the key itself)
app.get('/key-status', (req, res) => {
  res.json({ keyLoaded: Boolean(VT_API_KEY) });
});

// ---------- Password Checker (HIBP) ----------
app.get('/password-range/:prefix', async (req, res) => {
  const prefix = req.params.prefix.toUpperCase();

  // Only 5 hex characters (0-9, A-F) are allowed
  if (!/^[0-9A-F]{5}$/.test(prefix)) {
    return res
      .status(400)
      .json({ error: 'The prefix must be exactly 5 hex characters' });
  }

  try {
    const response = await fetch(
      `https://api.pwnedpasswords.com/range/${prefix}`
    );

    if (!response.ok) {
      return res
        .status(502)
        .json({ error: 'Could not get a response from the password database' });
    }

    const text = await response.text();

    // Every line looks like "SUFFIX:COUNT". Convert it to a JSON list.
    const results = text
      .split('\n')
      .map((line) => line.trim())
      .filter((line) => line.length > 0)
      .map((line) => {
        const [suffix, count] = line.split(':');
        return { suffix, count: Number(count) };
      });

    res.json(results);
  } catch (e) {
    res.status(500).json({ error: 'Something went wrong on the server' });
  }
});

// ---------- URL Scanner (VirusTotal) ----------

// Step 1: send the URL to VirusTotal
app.post('/url-scan', async (req, res) => {
  const { url } = req.body || {};

  // Validation: must be a string and not too long
  if (typeof url !== 'string' || url.length === 0 || url.length > 2000) {
    return res.status(400).json({ error: 'Please enter a valid URL' });
  }

  // Validation: must be a real URL using http or https
  let parsed;
  try {
    parsed = new URL(url);
  } catch (e) {
    return res.status(400).json({ error: 'The URL format is invalid' });
  }
  if (!['http:', 'https:'].includes(parsed.protocol)) {
    return res
      .status(400)
      .json({ error: 'Only http and https URLs are supported' });
  }

  if (!VT_API_KEY) {
    return res.status(500).json({ error: 'The server API key is not set' });
  }

  try {
    const response = await fetch(`${VT_BASE}/urls`, {
      method: 'POST',
      headers: {
        'x-apikey': VT_API_KEY,
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({ url: parsed.href }).toString(),
    });

    if (response.status === 429) {
      return res.status(429).json({
        error: 'Too many requests. Please wait a minute and try again',
      });
    }
    if (!response.ok) {
      return res
        .status(502)
        .json({ error: `Scanning service error: ${response.status}` });
    }

    const json = await response.json();
    res.json({ analysisId: json.data.id });
  } catch (e) {
    res.status(500).json({ error: 'Something went wrong on the server' });
  }
});

// Step 2: get the scan result
app.get('/url-report/:id', async (req, res) => {
  const id = req.params.id;

  // Validation: the id may only contain letters, numbers, - and _
  if (!/^[A-Za-z0-9_-]{1,200}$/.test(id)) {
    return res.status(400).json({ error: 'The analysis id is invalid' });
  }

  if (!VT_API_KEY) {
    return res.status(500).json({ error: 'The server API key is not set' });
  }

  try {
    const response = await fetch(`${VT_BASE}/analyses/${id}`, {
      headers: { 'x-apikey': VT_API_KEY },
    });

    if (response.status === 429) {
      return res.status(429).json({
        error: 'Too many requests. Please wait a minute and try again',
      });
    }
    if (!response.ok) {
      return res
        .status(502)
        .json({ error: `Scanning service error: ${response.status}` });
    }

    const json = await response.json();
    const attrs = json.data.attributes;
    const stats = attrs.stats || {};

    // Send back only the fields the app needs
    res.json({
      status: attrs.status, // queued, in-progress, completed
      stats: {
        malicious: stats.malicious || 0,
        suspicious: stats.suspicious || 0,
        harmless: stats.harmless || 0,
        undetected: stats.undetected || 0,
      },
    });
  } catch (e) {
    res.status(500).json({ error: 'Something went wrong on the server' });
  }
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});