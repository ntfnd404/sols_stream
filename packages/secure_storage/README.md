# secure_storage

**Capability package.** Encrypted key-value storage: the `SecureStorage`
contract plus its `flutter_secure_storage`-backed adapter, together in one
self-contained package. No domain semantics.

This is a **placeholder custody** for the current local-key signer. The chosen
account/identity model (see the Identity ticket) may replace it via a different
`SolanaSigner` implementation — the rest of the app depends on `SolanaSigner`,
not on this package.

## Public API

Barrel: `package:secure_storage/secure_storage.dart`

| Symbol | Kind | Description |
|---|---|---|
| `SecureStorage` | abstract interface | `get` / `set` / `remove` |
| `SecureStorageImpl` | final class | `flutter_secure_storage`-backed adapter |
| `SecureStorageException` | final class | Opaque failure type; carries no secret details |

## Dependencies

`flutter_secure_storage: 10.3.1`, Flutter SDK.

## Platform notes

`flutter_secure_storage` has per-platform requirements:

- **Android** — `minSdk >= 23` (met: Flutter default is 24).
  `android:allowBackup="false"` is set in the app manifest to avoid
  `InvalidKeyException` after a cloud restore.
- **iOS / macOS** — Keychain Sharing entitlement (`keychain-access-groups`)
  is declared in the Runner entitlements.
- **Web** — ⚠️ **open question.** `flutter_secure_storage` falls back to
  browser localStorage, which is not a secure store for a private key.
  Whether web is supported, and what it persists, is part of the Identity
  ticket — not decided here.
- **Linux** — requires `libsecret-1-dev` + `libsecret-1-0` and a running
  keyring service (e.g. `gnome-keyring`).
- **Windows** — requires the C++ ATL libraries from the Visual Studio
  Build Tools at compile time.

## Intentionally out of scope

- Solana keypair logic, balance, funding → `solana_wallet`
- Key derivation / mnemonic / Secure-Enclave-backed custody → Identity ticket
