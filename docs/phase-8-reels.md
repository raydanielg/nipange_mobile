# Phase 8 — Reels & Short Video

## Backend contract (verified)
- `GET /reels/feed/for-you|following|friends|trending|creators|explore` — real ranking feeds
- `POST /reels/:id/like` `/save` `/view` `/report` — interactions
- `GET/POST /reels/:id/comments` `/comments/:id/pin` `DELETE comments/:id` — comments
- `POST /reels/drafts` `/drafts/:id/attach` `/reels/:id/publish` `/reels/uploads` — upload lifecycle
- Model: `storageKey`, `coverKey`, `durationMs`, `status`(DRAFT|UPLOADED|READY|ARCHIVED|DELETED|REMOVED), `processingStatus`(PENDING|PROCESSING|READY|FAILED)

## Implemented
- `ReelsScreen` — PageView.vertical, one VideoPlayerController active at a time, disposes on swipe, tap play/pause, black immersive bg
- `reelsFeedProvider` — real `GET /reels/feed/for-you`
- `_ReelPage` — creator row (avatar + @username + Fuata), caption, action rail (like/comment/save/share/more) with real `_count` values
- URL resolution defensive: `videoUrl`/`playbackUrl`/`mediaUrl`/`url`/`storageKey` fallback
- Discover "Reels" entry → ReelsScreen

## BLOCKED BY BACKEND
- **No video download/playback route** — reel model stores `storageKey`/`coverKey`, dev storage provider only signs *upload* URLs, no `GET /media/:key` or `storage.getUrl()` exists. Reels will show "Video haipatikani bado" until a playback/download endpoint ships.
- HLS/rendition URLs — media pipeline outputs but no delivery contract

## NOT IMPLEMENTED
- Create-reel upload flow (draft→attach→publish endpoints exist, no mobile picker)
- Comments sheet on reels, follow action wiring, share, quality selection, watch-history
