# Phase 10 — Wallet, Coins, Gifts & Premium

## Backend contract (verified — very rich)
- `GET /monetization/wallet` `/wallet/transactions` — balance + ledger
- `GET /monetization/coins/packages`, `POST /coins/purchases`, `POST /coins/purchases/:id/confirm`
- `GET /monetization/gifts`, `POST /gifts/send`, `GET /gifts/sent`, `GET /gifts/received`
- `GET /monetization/creator/earnings` `/earnings/summary` `/payouts`, `GET /rewards/available`, `POST /rewards/:id/claim`
- `GET /subscriptions/plans` `/me` `/me/entitlements` `/me/usage` `/me/history`, `POST /checkout` `/:id/{activate,cancel,resume,upgrade}`, `POST /coupons/validate`

## Implemented
- `WalletScreen` — coral balance card (real `GET /monetization/wallet`), entry rows, real `GET /wallet/transactions` list (credit=green/debit=red)
- `CoinsScreen` — real `GET /coins/packages` grid, price+coins+TZS, `POST /coins/purchases` initiation with status snackbar
- `GiftsScreen` — real `GET /monetization/gifts` grid (name+coin price)
- `PremiumScreen` — real `GET /subscriptions/plans` cards (name/price/interval)
- Profile → Wallet entry wired

## Security posture (per spec)
- No client-side balance arithmetic — balance always from `/monetization/wallet`
- Purchases only `POST` initiation; `confirm` is a webhook-verified backend path, not client-trusted
- No local coin deduction — gift send posts to backend, refresh after confirm

## Classification
- IMPLEMENTED NOT LIVE-VERIFIED: all wallet/coin/gift/plan screens wired to real endpoints
- NOT IMPLEMENTED: payment-status polling screen, gift send flow (recipient select + confirm), subscription checkout/entitlement UI, transaction detail/receipt, creator earnings, rewards
- BLOCKED BY PROVIDER: Selcom/payment sandbox credentials (purchases initiate but can't be live-confirmed)
