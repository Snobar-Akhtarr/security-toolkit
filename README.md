# Security Toolkit

A Flutter app with its own Node.js backend that checks passwords against known data breaches and scans links for threats. I built it to learn **API integration** step by step, using real third-party APIs.


## Features

- **Password Checker:** finds out whether a password has appeared in known data breaches, using the Have I Been Pwned (Pwned Passwords) API.
- **URL Scanner:** sends a link to the VirusTotal API and shows how many security engines flagged it as malicious, suspicious, harmless or undetected.
- Clear loading, error and result states, including timeouts and readable error messages.
- Dark, custom-themed UI.

## How it works

```
Flutter app  -->  Node.js + Express backend  -->  HIBP / VirusTotal
Flutter app  <--  Node.js + Express backend  <--  HIBP / VirusTotal
```

### Password Checker (k-anonymity)

1. The app creates a SHA-1 hash of the password on the device.
2. Only the **first 5 characters** of the hash are sent to the backend.
3. The backend asks HIBP for all hashes that start with those 5 characters.
4. The app compares the rest of the hash locally, so the password and the full hash never leave the device.

### URL Scanner (POST + polling)

1. The app sends the URL to the backend with `POST /url-scan`.
2. The backend validates it and forwards it to VirusTotal, which returns an analysis id.
3. The app polls `GET /url-report/:id` until the scan status is `completed`.

### Why a backend?

- The VirusTotal API key stays on the server (in a `.env` file) instead of inside the app.
- All input is validated on the server before it is used.
- The backend returns only the fields the app needs.

## Tech stack

- **Frontend:** Flutter, Dart, `http`, `crypto`
- **Backend:** Node.js, Express
- **APIs:** Have I Been Pwned (Pwned Passwords), VirusTotal

## Concepts practiced

REST APIs, GET and POST requests, headers, JSON parsing, model classes (`fromJson`), service classes, `async`/`await`, polling, timeouts, error handling, input validation, hashing (SHA-1), k-anonymity, and keeping secrets out of source control with `.env` and `.gitignore`.

## Project structure

```
security-toolkit/
├── lib/
│   ├── main.dart
│   ├── theme/            # colors and theme
│   ├── widgets/          # shared UI widgets
│   ├── screens/          # home, password checker, URL scanner
│   ├── services/         # API calls (password_service, url_service, api_config)
│   └── models/           # data classes
├── screenshots/
└── security_toolkit_backend/
    └── server.js         # Express server and endpoints
```

## Getting started

### Requirements

- Flutter SDK
- Node.js 20.12 or newer
- A free [VirusTotal](https://www.virustotal.com) account and API key

### 1. Run the backend

```bash
cd security_toolkit_backend
npm install
```

Create a file named `.env` in the `security_toolkit_backend` folder:

```
VT_API_KEY=your_virustotal_api_key_here
```

Start the server:

```bash
node server.js
```

It runs at `http://localhost:3000`.

### 2. Run the Flutter app

From the project root:

```bash
flutter pub get
flutter run
```

The server address is set in `lib/services/api_config.dart`:

- Android emulator: `http://10.0.2.2:3000` (default)
- Real phone on the same Wi-Fi: use your computer's local IP, for example `http://192.168.1.5:3000`

The Android manifest allows plain `http` traffic for local development. Remove that setting when the backend is deployed behind HTTPS.

## Backend endpoints

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/password-range/:prefix` | Returns hash suffixes and counts for a 5-character prefix |
| POST | `/url-scan` | Sends a URL to VirusTotal and returns an analysis id |
| GET | `/url-report/:id` | Returns scan status and engine statistics |

## Limitations

- The backend runs locally and is not deployed yet.
- The free VirusTotal key has a low request limit, so scans can fail with a "too many requests" message.
- "No known leaks" or "No threats found" does not mean something is completely safe. It only means nothing was found in the data sources used.
- Only scan public links. URLs sent to VirusTotal may be visible to other users of that service.

## What I learned

Seeing both sides of an API call, the client that sends a request and the server that answers it, made the concepts click. The happy path was the easy part. Validation, timeouts, secret handling and readable error messages are what make an integration reliable.

## Credits

- [Have I Been Pwned](https://haveibeenpwned.com) for the Pwned Passwords API
- [VirusTotal](https://www.virustotal.com) for the URL scanning API

## Author

Snobar Akhtar

- GitHub: [Snobar-Akhtarr](https://github.com/Snobar-Akhtarr)
- LinkedIn: [snobar-akhtar-b4a33a413](https://www.linkedin.com/in/snobar-akhtar-b4a33a413)
