#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Full build: regenerate the data-dependent assets, render the site, and
# (optionally) publish to Netlify.
#
# Flags:
#   --no-publish   skip the final `quarto publish` step (render + assets only)
#   --skip-data    skip the RUCC map rebuild (fast path when data hasn't moved)
#   --skip-og      skip the OG card rebuild
#
# Typical usage:
#   scripts/build.sh              # regen everything and publish
#   scripts/build.sh --no-publish # build locally, don't deploy
# -----------------------------------------------------------------------------

set -euo pipefail

PUBLISH=1
REGEN_DATA=1
REGEN_OG=1

for arg in "$@"; do
  case "$arg" in
    --no-publish) PUBLISH=0 ;;
    --skip-data)  REGEN_DATA=0 ;;
    --skip-og)    REGEN_OG=0 ;;
    *) echo "Unknown flag: $arg" >&2; exit 1 ;;
  esac
done

# Run from the project root regardless of where the script is invoked
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

say() { printf "\033[1;32m▸ %s\033[0m\n" "$*"; }

if [[ $REGEN_DATA -eq 1 ]]; then
  say "Regenerating RUCC map (Rscript scripts/rucc-map.R)"
  Rscript scripts/rucc-map.R
fi

if [[ $REGEN_OG -eq 1 ]]; then
  say "Regenerating OG cards (python3 scripts/generate-og.py)"
  python3 scripts/generate-og.py
fi

# Sweep stale quarto session-temp files. A crashed `quarto preview` can leave
# these orphaned; on the next `quarto publish` the project walker stats them
# mid-GC and crashes with a NotFound on the temp path. Safe to remove any time.
if [[ -d .quarto ]]; then
  find .quarto -maxdepth 2 -name 'quarto-session-temp*' -delete 2>/dev/null || true
fi

if [[ $PUBLISH -eq 1 ]]; then
  say "Publishing to Netlify (quarto publish netlify)"
  quarto publish netlify
else
  say "Rendering site only (quarto render)"
  quarto render
fi

say "Done."
