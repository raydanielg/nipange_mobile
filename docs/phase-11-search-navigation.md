# Phase 11 — Global Search & Navigation

## Backend contract (verified)
- `GET /search?q&type&limit` — categories all/people/posts/reels/hashtags
- `GET /search/autocomplete?q` — suggestion list
- `GET /search/trending` — backend-ranked trending queries
- `GET /search/history` + `DELETE /search/history` + `DELETE /search/history/:id` — server-synced history

## Implemented
- `SearchScreen` — dedicated search UX:
  - Debounced input (350ms, cancels prior timer) — not per-keystroke
  - Category tabs: Zote/Watu/Posts/Reels/Hashtags → `type` param
  - Autocomplete suggestions while typing
  - Backend-synced recent searches (tap to re-run, individual + clear-all delete)
  - Trending section from real `/search/trending`
  - Results rendered with type→icon mapping
- Home search icon → `SearchScreen`

## Classification
- IMPLEMENTED NOT LIVE-VERIFIED: all search paths wired to real endpoints
- NOT IMPLEMENTED: named-route registry/GoRouter deep links, result→destination navigation (profile/post/reel open), regional filters, request cancellation via CancelToken
