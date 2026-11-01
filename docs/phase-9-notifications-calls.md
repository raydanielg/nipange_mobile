# Phase 9 — Notifications & Calls

## Backend contract (verified)
- `GET /communications/notifications` (cursor), `GET /unread-count`, `PATCH /notifications/read-all`, `PATCH /notifications/:id/read`, `GET/PATCH /preferences`, `POST/GET /devices`
- Calls: `POST /calls` (ring), `POST /calls/groups`, `POST /calls/:id/{accept,reject,cancel,end,connected,signal,join}`, `GET /calls/history`, `/history/missed`, `GET /calls/ice-servers`, `GET/PATCH /calls/settings`
- SFU: `DevSfuProvider` — issues `dev-sfu:room:acct:role:ts` dev tokens, **no real media transport**; `LIVEKIT_*`/`TURN_*` env documented but unconfigured

## Implemented
- `NotificationsScreen` — real `/communications/notifications`, unread tint + dot, type→icon mapping, tap→`PATCH :id/read` + refresh, "Soma zote"→`PATCH read-all`, pull-refresh
- `CallsScreen` — real `/calls/history`, missed=red, voice/video icons, status+time, tap→call-back sheet (voice/video) → `POST /calls` ring
- Home bell → NotificationsScreen; chat appbar → CallsScreen

## Classification
- IMPLEMENTED NOT LIVE-VERIFIED: notifications list/read/read-all, call history, call initiation
- BLOCKED BY PROVIDER: FCM/APNs (no creds), real SFU media (DevSfu is dev-token only — LiveKit/TURN unconfigured)
- NOT IMPLEMENTED: incoming-call UI, active-call controls (mute/speaker/camera), Socket `call:*` listeners, call permissions, deep-link routing, notification preferences UI
