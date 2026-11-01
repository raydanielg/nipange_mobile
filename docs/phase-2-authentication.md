# Phase 2 — Authentication & Onboarding

## Backend contract (verified)
- `POST /auth/register/phone` — `{phone:E.164, password?>=12, displayName?}` → `{challengeId}`
- `POST /auth/register/verify` — `{challengeId, code}` → `{tokens:{accessToken,refreshToken}, user}`
- `POST /auth/login` — phone or email + password → tokens
- `POST /auth/refresh` — rotation; `POST /auth/logout`; sessions + `logout-all`
- Login also supports `login/otp` + `login/otp/verify` + OAuth google/apple routes exist
- Age: no DOB field on register — enforced at `/profiles/me` PATCH + dating eligibility (18+ backend)

## Implemented
- `WelcomeScreen` — hero + EN/SW `SegmentedButton` toggle + legal links + CTA to register/sign-in
- `RegisterFlow` — 3-step progress (phone→OTP→profile) with `LinearProgressIndicator`
  - Phone: `Validators.normalizePhone` E.164 (+255/0/255 prefixes), real `/register/phone`
  - OTP: 6-digit centered input, 60s resend countdown, real `/register/verify` → tokens stored
  - Profile: displayName + DOB picker (client 18+ check via `Validators.isAdult`) + optional password → `PATCH /profiles/me`
- `validators.dart` — pure testable utils (normalizePhone/age/passwordError)
- Auth state restored via refresh on boot; logout clears secure storage

## Tests
- 13/13 — phone normalize (5 cases), age boundaries incl. 18th-birthday-today (4), password min-12 (2), + theme/sheet (2)

## Gaps
- Backend has no age check on register — enforced server-side only at profile/dating eligibility (documented, not a mobile bypass since backend independently gates dating)
- Recovery: `forgot-password` DTO exists but no controller route found — not wired (flagged, not faked)
- No image upload (backend presign gap — documented in audit)
- Email register path not surfaced in UI (backend supports — mobile kept phone-first per spec)
