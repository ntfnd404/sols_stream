# Security Model

Workflow Version: 3

## Secret Classes

| Secret / Sensitive Value | Risk | Rule |
|---|---|---|
| `prot` | Removed legacy invite capability parameter retained in redaction tests | Never accept in canonical invites; continue redacting historical values |
| `passphrase` | Decrypts protected-slot SDP payloads | Never log; never place in app-wide events |
| `protectedKey` | Broker capability handle | Treat as sensitive; redact in diagnostics |
| HLS Basic/Bearer credentials | Grants playback access | Never include in `toString`, UI errors, or logs |
| Wallet private key bytes | Controls funds/identity | Stays in wallet adapter/storage only |
| SDP / ICE / TURN data | May reveal network and session metadata | Never log |

## Logging And Errors

- Global reporters use a closed `SafeDiagnosticContext` with a stable code. In
  debug/profile they may include `runtimeType` and a runtime stack. Release
  builds include neither because stack and type text are not trusted telemetry.
  Unknown exceptions are never rendered with `toString()`.
- User-visible statuses must use safe, typed messages, not raw `$e`.
- External error bodies from brokers, RPC, plugins, or platform channels are
  not trusted. Provider adapters must replace them with typed failures that
  retain the original stack trace but not the provider object or message.
  Solana reads, key-broker access, and secure storage currently enforce this;
  the global formatter remains the fallback for unknown paths.
- `Redactor` is for known text and URI shapes. It is not a security boundary for
  arbitrary exception messages or response bodies.
- `LocalKeyBrokerGateway` is a development-only capability adapter selected
  explicitly by `APP_ENVIRONMENT=local` and `KEY_BROKER_MODE=local`. Its
  envelope is scoped and expiring but not confidential from readers of local
  validator state. Dev and production must use the HTTPS proof-verifying
  broker.
- Remote broker requests do not spoof browser headers and never follow
  redirects. The broker must support ordinary native clients and CORS for
  approved Web origins.
- Provider failures never contribute broker endpoint, response body, or raw
  message text to diagnostics. Startup environment diagnostics may describe a
  separately configured broker URL only through `Redactor`, which removes URL
  credentials, query values, and fragments. Passphrase, protected key, proof,
  and response body are never logged.
- Signaling diagnostics use fixed lifecycle namespaces (`publisher.*`,
  `host.*`, `chain.*`, `viewer.*`, `slot.*`, `transaction.*`) and may append
  only an exception `runtimeType`. They must never append raw exception
  messages or payload data.
- Wallet addresses are linkable financial identifiers. Full addresses are
  never written to diagnostics or logs in any environment. They may be shown
  in user-facing identity UI. Private key material and signed proof payloads
  may not be logged or displayed.
- Reference JS code is not production source. Its debug logging is an anti-pattern
  inventory for the Dart rewrite, not behavior to port.

## Provider Failure Boundary

`SS-0013` establishes two layers of protection. Solana read adapters publish
sanitized typed failures without retaining provider objects, and app-wide
reporters render only the fields allowed by the current build policy. Retry remains explicit:
only `TransientSignalingReadException` is retryable; terminal read failures are
not inferred from provider text.

The reporter policy is build-sensitive: debug/profile output contains stable
context plus type/stack for development, while release output contains only the
stable context code and label. A future crash reporter accepts a normalized DTO,
never the original exception object; this work is tracked by SS-0023.

## Review Rule

Any change to secrets, crypto, storage, signing, capability URLs, package trust
boundaries, or redaction policy is Critical and requires security-reviewer.
