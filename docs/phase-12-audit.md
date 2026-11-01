# Phase 12 — Audit

## Working (compile + real endpoints wired)
- Auth (register/OTP/login/refresh/logout), Home feed, Discover/Search, Chats+Socket.IO, Stories row, Reels player, Notifications, Call history+ring, Wallet/Coins/Gifts/Premium, Profile+edit, Settings (privacy/notif/sessions/deactivate/delete), Safety (blocks/report categories)

## Backend gaps
- No video playback/download URL (reels blocked)
- No media upload picker wiring (upload-url exists)
- FCM/APNs + LiveKit/TURN credential-blocked
- DevSfuProvider — dev tokens only, no real media

## Security findings
- Tokens in SecureStore (not SharedPreferences) ✓
- No hardcoded secrets ✓ · HTTPS via env `API_URL` ✓
- 401→refresh→retry + logout-on-fail ✓
- Privacy toggles hit real `/safety/privacy` — not local-only
