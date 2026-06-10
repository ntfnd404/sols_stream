# solana_wallet

**Bounded context:** Solana wallet — identity, signing, balance, and funding.

Owns the Solana keypair lifecycle (generation, encrypted persistence, recovery)
and publishes narrow ports for other contexts and the UI to depend on. The
private key never leaves the context — callers can request a signature but can
never read key material.

## Published ports (the only public surface)

| Port | Responsibility |
|------|----------------|
| `SolanaSigner` | `publicKey` + `signAndSend(instructions) → signature`. Sign only. |
| `WalletAccount` | `publicKey` / `address` / `getBalance()` / `ensureFunded()`. |
| `FundingGateway` | Funding port; `AirdropFaucetFundingGateway` is the airdrop+faucet adapter (devnet). |
| `WalletStorageException` | Typed failure for unreadable/corrupt key material. |

`SolanaWalletAssembly.create(...)` resolves the keypair and exposes `signer` +
`account`. It never exposes the concrete adapter, the keypair, or the
`RpcClient`.

```dart
final wallet = await SolanaWalletAssembly.create(
  storage: secureStorage,
  rpc: rpc,
  fundingGateway: AirdropFaucetFundingGateway(rpcClient: airdropRpc,
      httpClient: http.Client(), faucetUri: faucetUri, minLamports: ...,
      airdropLamports: ...),
  storageKey: 'sols_stream_wallet_v1',
);
wallet.signer;   // SolanaSigner  — passed to the signaling context
wallet.account;  // WalletAccount — balance/funding for the UI
```

## Layers (Clean Architecture)

```
src/
  domain/   ports + WalletStorageException — pure contracts (no RpcClient)
  data/     adapters: WalletKeyStore (SecureStorage), AirdropFaucetFundingGateway
            (RpcClient + http.Client), SolanaWallet (implements the ports)
  solana_wallet_assembly.dart   composition of the context
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
- **Devnet-only funding** is explicit and swappable: `AirdropFaucetFundingGateway`
  lives behind the `FundingGateway` port; mainnet uses a different adapter. Funding
  thresholds and the storage key are injected by the composition root, so the
  package holds no app-specific constants.
- **Account is fixed for the app lifetime** — runtime account switching / logout
  is out of scope (tracked in SS-0004).

## Dependencies

| Package | Why |
|---------|-----|
| `secure_storage` | Encrypted private-key persistence (port) |
| `solana` | RPC client, keypair, transactions |
| `http` | Devnet faucet fallback |

## Testing

- `WalletKeyStore` and `AirdropFaucetFundingGateway` are unit-tested (fake `SecureStorage`;
  mocktail-mocked `RpcClient` + `http.Client`).
- `SolanaWallet.signAndSend` is **not** unit-tested: `signAndSendTransaction` is
  an extension method on `RpcClient` (statically dispatched, not mockable). It is
  covered by integration testing only.

## TODO

- Migrate to Secure Enclave-backed custody — see SS-0004 (note: Enclave is
  P-256; Solana is Ed25519, so envelope encryption, not direct key storage).
