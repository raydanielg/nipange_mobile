# Phase 6 — Real-Time Messaging

## Backend contract (verified in repo)
- Gateway: `@WebSocketGateway({namespace:'/messaging'})` — token auth handshake, rooms `conv:{id}`
- Events: `conversation:join/leave`, `message:send`→`message:new`, `message:read`, `typing:start/stop`→`typing:update`, `presence:update`, `presence:heartbeat`
- REST: `GET/POST /messaging/conversations`, `direct`, `group`, `mute/unmute/pin/unpin/archive/mark-unread`, `GET/POST .../messages`, `/read`, `/delivered`, `/receipts`, `/typing`, `/search`, `/messages/:id/reactions`, `/messages/:id/forward`, `/attachments/upload-url`

## Implemented
- `MessagingSocket` — singleton Socket.IO on `/messaging`, `setAuth({token})`, `enableReconnection`, join/leave/typing lifecycle, `on/off/emit`
- `ConversationScreen` — real `GET .../messages` history + live `message:new` merge, `typing:update`→"anaandika…", typing debounce (1.5s auto-stop), `POST .../read` on open, keyboard-aware composer
- Bubble alignment via real `GET /accounts/active` → `senderAccountId == myId` (right=coral-out, left=grey-in, asymmetric radius)
- Long-press action sheet — Copy / React (`POST .../reactions`) / Forward (`POST .../forward`) — real endpoints
- Chat list → ConversationScreen navigation wired

## Gaps
- Media/voice/doc sends (upload-url exists but no mobile picker wired)
- Group creation/management UI, presence indicator in appbar, offline queue, delivery-tick icons per message, notification deep-links
- FCM/APNs — credential-blocked backend-side
