#!/usr/bin/env bash
set -euo pipefail

readonly version="v0.24.2"
case "$(uname -m)" in
  x86_64)
    readonly archive="lychee-x86_64-unknown-linux-gnu.tar.gz"
    readonly expected_sha256="1f4e0ef7f6554a6ed33dd7ac144fb2e1bbed98598e7af973042fc5cd43951c9a"
    ;;
  aarch64)
    readonly archive="lychee-aarch64-unknown-linux-gnu.tar.gz"
    readonly expected_sha256="91a7bd65685da41b90ccb9bc867a3d649a7818042dae04ff405e55a25bddee4c"
    ;;
  *)
    printf 'Unsupported runner architecture: %s\n' "$(uname -m)" >&2
    exit 1
    ;;
esac

readonly runner_temp="${RUNNER_TEMP:-${TMPDIR:-/tmp}}"
readonly install_dir="$runner_temp/lychee/bin"
readonly work_dir="$(mktemp -d "$runner_temp/lychee-download.XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT

curl --fail --location --silent --show-error \
  --retry 2 --connect-timeout 10 --max-time 60 \
  --output "$work_dir/$archive" \
  "https://github.com/lycheeverse/lychee/releases/download/lychee-$version/$archive"

printf '%s  %s\n' "$expected_sha256" "$work_dir/$archive" | sha256sum --check --status || {
  printf 'Lychee %s release digest mismatch for %s\n' "$version" "$archive" >&2
  exit 1
}

tar --extract --gzip --file "$work_dir/$archive" --directory "$work_dir"
lychee_binary="$(find "$work_dir" -type f -name lychee -print -quit)"
if [[ -z "$lychee_binary" || ! -s "$lychee_binary" ]]; then
  printf 'Verified Lychee binary is missing or empty\n' >&2
  exit 1
fi

install -D -m 0755 "$lychee_binary" "$install_dir/lychee"
printf '%s\n' "$install_dir" >> "$GITHUB_PATH"
printf 'Installed Lychee %s with a verified SHA-256 digest\n' "$version"
