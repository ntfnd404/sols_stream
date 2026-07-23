# solana_wallet

**Bounded context:** Solana wallet — identity, signing, balance, and funding.

Owns the current Solana keypair lifecycle (generation and encrypted
persistence) and publishes narrow ports for other contexts and the UI to depend
on. The private key never leaves the context — callers can request a signature
but can never read key material.

## Published ports (the only public surface)

| Port | Responsibility |
|------|----------------|
| `SolanaSigner` | `publicKey` + confirmed `signAndSend(instructions) → signature`. Sign only. |
| `SolanaTransactionException` | Structured send/confirmation failure with kind, signature, instruction index, custom program code, and immutable program logs. |
| `SolanaWalletReader` | Read-only `address` and `getBalanceLamports()` capability for UI and diagnostics. |
| `SolanaFundingService` | Workspace-internal minimum-balance precondition used by `signaling_solana`. Its temporary `bool` result is tracked by SS-0005. |
| `WalletStorageException` | Typed failure for unreadable/corrupt key material. |

`SolanaWalletAssembly.create(...)` resolves the keypair, builds the selected
funding strategy, and exposes `signer`, `reader`, and `fundingService`. It never exposes the
concrete adapter, keypair, funding sources, or `RpcClient`.

```dart
final wallet = await SolanaWalletAssembly.create(
  storage: secureStorage,
  rpc: rpc,
  funding: RpcAirdropWithFaucetFundingConfig(
    minimumBalanceLamports: minimumBalance,
    airdropRpcUri: airdropRpcUri,
    faucetUri: faucetUri,
    airdropLamports: requestedLamports,
  ),
  storageKey: 'sols_stream_wallet_dev_v1',
);
wallet.signer;          // signing capability for provider adapters
wallet.reader;          // address and lamports for the UI
wallet.fundingService;  // internal precondition for signaling_solana
await wallet.dispose();
```

## Layers (Clean Architecture)

```
src/
  domain/   ports + WalletStorageException — pure contracts (no RpcClient)
  data/     adapters: WalletKeyStore, SolanaWallet, transaction confirmer
    funding/
      ConfirmedBalanceFundingGateway — policy and confirmation
      RpcAirdropFundingSource        — Solana JSON-RPC adapter
      HttpFaucetFundingSource        — sols.stream faucet adapter
  funding_config/              typed assembly configurations
  solana_wallet_assembly.dart  composition and owned-resource lifecycle
```
There is no `application/` layer — the context has no multi-step use cases, so an
empty layer is avoided (KISS). `SolanaWallet` holds the `RpcClient`, so it is a
**data adapter**, not application.

## Design notes

- **No silent identity loss:** `WalletKeyStore.loadOrCreate` creates a key only
  when none is stored. A present-but-unreadable key throws
  `WalletStorageException` rather than regenerating (which would abandon the
  funded account). `SecureStorageException` is wrapped into the wallet type.
- **`RpcClient` never leaks** through a port — it is transport/infrastructure.
  The signaling context reads chain accounts via its own injected `RpcClient`.
- **Submitted is not confirmed:** `SolanaWallet` fetches a blockhash, signs once,
  sends once, and observes that exact signature until it reaches `confirmed` or
  `finalized`, fails on-chain, or passes its last valid block height. A transport
  failure after signing never creates a second transaction implicitly.
- **Failure details remain structured:** failures preserve the signature,
  instruction index, custom program code, generic transaction error, and
  immutable program logs without exposing raw RPC JSON. Exception messages are
  sanitized; program logs are not and must not be logged automatically.
- **Funding policy is typed assembly configuration:** local uses
  `RpcAirdropFundingSource`; dev tries RPC airdrop and then
  `HttpFaucetFundingSource`; production passes an empty source list and only
  verifies the confirmed balance. No nullable provider selects a hidden mode.
- **Balance confirmation is shared:** `ConfirmedBalanceFundingGateway` checks
  the primary cluster balance before funding. Accepted or indeterminate
  requests are reconciled and end the current attempt, preventing a late
  deposit from racing a fallback. Only a source outcome that explicitly permits
  fallback moves to the next source. Sources do not duplicate policy or polling.
- **Funding outcomes are explicit:** `accepted` means confirmation is pending,
  `fallbackAllowed` means local/dev policy permits the next source, and
  `indeterminate` means a transport failure may have happened after dispatch.
- **Dev fallback is intentionally availability-oriented:** the Solana SDK does
  not expose the status carried by its `HttpException`, so local/dev RPC HTTP
  rejection permits the configured faucet fallback. Production cannot select
  an external funding source.
- **App-specific values stay outside the package:** thresholds, requested
  lamports, endpoints, and storage keys arrive through typed configuration.
- **Resource ownership is local:** the assembly owns only clients it creates.
  The shared primary RPC remains app-owned because the current SDK has no
  close API.
- **Solana identity is fixed for the app lifetime** — runtime account switching / logout
  is out of scope (tracked in SS-0004).

## Dependencies

| Package | Why |
|---------|-----|
| `secure_storage` | Encrypted private-key persistence (port) |
| `solana` | RPC client, keypair, transactions |
| `http` | Devnet faucet fallback |

## Testing

- `WalletKeyStore`, each funding source, `ConfirmedBalanceFundingGateway`, and
  `SolanaTransactionConfirmer` are unit-tested (fake `SecureStorage`;
  mocktail-mocked `RpcClient` + `http.Client`).
- Confirmation polling, on-chain failures, timeout sanitization, fallback
  ordering, and indeterminate funding reconciliation are covered by unit tests.
- Local-validator and devnet integration coverage is deferred under roadmap
  item `BL-001`; this package does not claim that coverage yet.

## TODO

- Resolve the production custody and recovery model under SS-0004 before
  production launch. This includes backup/import, key rotation, and Web
  multi-context consistency; no storage technology is selected yet.
