#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

if git diff --cached --quiet; then
  echo "No staged changes to verify." >&2
  exit 2
fi

git diff --cached --check

tree="$(git write-tree)"
snapshot="$(printf 'verify staged tree %s\n' "$tree" | git commit-tree "$tree" -p HEAD)"
temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/sols-stream-staged.XXXXXX")"
worktree="$temporary_root/worktree"

cleanup() {
  git -C "$root" worktree remove --force "$worktree" >/dev/null 2>&1 || true
  rm -rf "$temporary_root"
}
trap cleanup EXIT INT TERM

git worktree add --quiet --detach "$worktree" "$snapshot"
cd "$worktree"

echo "=== Staged Snapshot ==="
echo "tree=$tree"
echo "snapshot=$snapshot"
echo "parent=$(git rev-parse HEAD^)"
echo "lockfile=$(git hash-object pubspec.lock)"
dart --version
flutter --version

echo "=== Locked Dependencies ==="
flutter pub get --enforce-lockfile
(
  cd tool/solana_codegen
  dart pub get --enforce-lockfile
)

echo "=== Package Checks ==="
for package in signaling signaling_solana solana_wallet; do
  (
    cd "packages/$package"
    dart analyze --fatal-infos
    dart test
  )
done

echo "=== Application Checks ==="
flutter analyze --fatal-infos --fatal-warnings
flutter test test/architecture
flutter test

echo "=== Generated SDK ==="
(
  cd tool/solana_codegen
  dart run solana_idl_codegen generate ../../packages/signaling_solana/idl/sols_stream.json \
    --input-root ../../packages/signaling_solana/idl \
    --output ../../packages/signaling_solana/lib/src/generated \
    --layout modular \
    --check
)

echo "Verified staged tree $tree"
