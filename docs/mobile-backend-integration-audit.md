# NIPANGE Mobile ↔ Backend Integration Audit
Verified against `nipange-backend` (211 e2e tests green). Base: `{BASE_URL}/api/v1`, JWT Bearer access token + refresh rotation, Socket.IO namespace `/messaging`, response envelope `{success, data}` / `{error: {code, message}}`.

## API AVAILABLE (verified e2e)
- Auth: `POST /auth/register/phone`, `POST /auth/register/verify` (OTP), `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`, sessions list/revoke, TOTP 2FA
- Accounts: `GET /accounts`, `POST /accounts`, `POST /accounts/:id/switch`
- Profiles: `GET/PATCH /profiles/me`, `GET /profiles/:username`, visibility, dating/creator sub-profiles, completion
- Locations: regions/districts/wards tree, manual+GPS location, nearby discovery (Haversine)
- Safety: blocks, mutes, reports, privacy settings, enforcement
- Social graph: follow/unfollow, friends, follow status
- Dating: `GET /dating/discover` (18+ enforced), like/pass/superlike, matches, preferences
- Messaging: `GET/POST /messaging/conversations`, messages CRUD, read receipts, typing, groups — REST + Socket.IO `/messaging` (`message:new`, `message:read`, `typing`, `presence:update`)
- Feed: posts/comments/reactions/reposts/polls, `GET /feed/following`, `GET /feed/explore`, hashtags
- Stories: create/list/view/react — 24h server-side expiry
- Reels: create/view/react/comment/save, `GET /reels/feed`, `markProcessed` contract
- Calls: `POST /calls`, state machine (ringing/active/ended), SDP/ICE exchange, history
- Monetization: coin packages, purchases, gifts send, wallets, immutable ledger
- Subscriptions: plans, subscribe, entitlements, quotas
- Comms: notifications inbox, read/unread, preferences, devices (push token register)
- Admin: RBAC + audit (not for mobile)
- Analytics: `POST /analytics/events` (whitelisted types), `GET /analytics/me/overview`, recommendations reels/dating/creators, feedback
- Search: `GET /search?q&type`, autocomplete, trending, history

## API PARTIALLY AVAILABLE
- Media upload: `storageKey` references in posts/reels/stories — no presigned-upload endpoint found; mobile must upload binary then reference key (contract gap)
- Calls: signaling REST exists; real SFU media needs LiveKit/TURN credentials (dev tokens only)
- Push: `POST /communications/devices` exists; real FCM/APNs delivery is credential-blocked backend-side
- Payments: purchase confirm contract; real Selcom adapter not wired (webhook contract)

## API MISSING
- Media file upload endpoint (multipart/presign) — needed for photos/video
- Story highlight endpoints
- Call history UI endpoint exists via `/calls` list — verify exact route at integration
