# Ubiquitous Language

Workflow Version: 3

This vocabulary describes product and protocol concepts independently of Dart
class names. Public APIs should use these terms consistently.

## Participants And Sessions

- **Publisher** — presentation role for a participant who publishes media. In
  the current P2P flow, a Publisher acts as the signaling Host. The terms are
  not interchangeable outside that flow because future publication topologies
  may not use an on-chain host room.
- **Host** — participant that creates a room, publishes an offer, and owns the
  advertised signaling session.
- **Viewer** — participant that accepts an invite, claims an available slot,
  reads the offer, and submits an answer.
- **Room** — host-owned on-chain session container. Ending a room stops new
  participation; closing it reclaims its account rent.
- **Slot** — on-chain rendezvous record inside a room through which one host and
  one viewer exchange protected signaling data.
- **Invite** — canonical HTTP(S) link that identifies the host and access mode.
  It is routing data, not a container for plaintext key material.

## Signaling Exchange

- **Offer** — host's proposed WebRTC session description.
- **Answer** — viewer's accepted WebRTC session description.
- **Claim** — atomic transition reserving an available slot for a viewer.
- **Connection confirmation** — on-chain acknowledgement that a participant
  completed the signaling exchange. It is distinct from transaction
  confirmation, which describes cluster commitment for a submitted Solana
  transaction.
- **Heartbeat** — periodic proof that an active session is still live and must
  not be reclaimed as stale.
- **Protected slot** — slot whose encrypted payload requires a broker-issued
  capability and proof before its passphrase can be released.

## Lifecycle And Wallet

- **Reclaim** — best-effort recovery operation that closes eligible stale or
  completed accounts and returns recoverable deposit/rent according to program
  rules. A failed reclaim may leave value for later cleanup. Reclaim must remain
  possible at a low wallet balance and therefore bypasses automatic funding.
- **Funding precondition** — check that confirms the wallet's configured
  minimum SOL balance immediately before a funded broadcast. Local/dev may use
  configured funding sources; production only observes the existing balance.
  It is not transaction budgeting and does not guarantee transaction success.
- **Participant identity** — one public key used consistently for ownership,
  signing, address presentation, and invite validation. Private key material is
  never part of signaling language.
