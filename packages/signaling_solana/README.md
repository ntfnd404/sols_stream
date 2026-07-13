# signaling_solana

Solana adapter for the `signaling` bounded context.

This package owns Solana program wire details:

- the reproducibly generated Anchor wire SDK;
- application-owned compatibility decoders and domain mappers;
- instruction composition, chunking, and transaction sequencing;
- Solana chain gateway;
- protected-slot gateway;
- reclaim gateway and Anchor error decoding;
- `SignalingSolanaAssembly` for production composition.

It implements ports published by `package:signaling/signaling.dart`.
The `signaling` package must not import this package or `solana_wallet`.

## Versioned IDL

The adapter-owned Anchor IDL is checked in at `idl/sols_stream.json`.

```bash
make check-idl
make fetch-idl
make generate-solana-sdk
make check-solana-sdk
```

The fetcher lives at `tool/fetch_idl.dart`, accepts an explicit `--rpc-url` (or
`SOLANA_RPC_URL`), and supports `--check` without modifying the artifact.
The root Make targets pass `IDL_RPC_URL` from `config/tooling/idl.env`; that
tooling environment is independent of Flutter application dart-defines.
The generated SDK lives under `lib/src/generated`. It is omitted from the
package's public barrel but committed to Git so a clean checkout remains
buildable. It is produced through the CLI by the pinned standalone tool package
at `tool/solana_codegen`; keeping that tool outside the Flutter workspace avoids
coupling generator analyzer dependencies to Flutter SDK version pins.
The package analyzer excludes `lib/src/generated`: generated sources are
validated by the generator's analyzer matrix, drift check, consumer
compilation, and wire-level tests rather than application-specific style rules.

After an IDL or generator update, review the versioned IDL, generated diff, and
pinned tooling manifest/lock changes, then run the drift check and consumer tests.
Protocol policy such as chunking, proof instructions, retry/idempotency,
sequencing, and legacy account compatibility remains handwritten in this
adapter.

## Commands

| Command | Purpose | Side effects |
|---|---|---|
| `make check-idl` | Compare deployed Anchor IDL with the versioned JSON. | Read-only; exits non-zero on drift. |
| `make fetch-idl` | Refresh the versioned Anchor IDL. | Writes `idl/sols_stream.json` when content changes. |
| `make generate-solana-sdk` | Regenerate the internal modular wire SDK. | Updates `lib/src/generated`. |
| `make check-solana-sdk` | Verify committed generated output matches the IDL and pinned generator. | Read-only; exits non-zero on missing output or drift. |
