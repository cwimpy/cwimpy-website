#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Quarto post-render hook (registered under project: post-render in _quarto.yml).
#
# Quarto runs this after every render, including the render that
# `quarto publish netlify` performs, and before anything is uploaded. It does
# three things to the output folder:
#
#   1. Deletes macOS/iCloud sync duplicates ("index 2.html", "site_libs 3/").
#      These pile up in _site because the repo lives in a synced folder, and
#      they were being deployed as public pages (cwimpy.com/index 2.html).
#      A file is only deleted when its un-numbered twin exists next to it, so
#      a real file such as "Figure 1.png" is never touched.
#
#   2. Empties the output folders of draft posts down to Quarto's blank stub,
#      so a draft's featured image or PDF is not deployed.
#
#   3. Removes utility pages from sitemap.xml (style guide, thank-you, 404).
#      Quarto has no per-page "leave this out of the sitemap" option.
# -----------------------------------------------------------------------------

set -euo pipefail

OUT="${QUARTO_PROJECT_OUTPUT_DIR:-_site}"
[[ -d "$OUT" ]] || exit 0

# --- 1. Sync duplicates ------------------------------------------------------
# -depth lists a folder's contents before the folder itself, so a duplicate
# folder is removed in one step after anything inside it has been considered.
removed=0
while IFS= read -r -d '' path; do
  [[ -e "$path" ]] || continue                 # already gone with its parent
  name="$(basename "$path")"
  dir="$(dirname "$path")"
  # "index 2.html" -> "index.html";  "site_libs 10" -> "site_libs"
  twin="$(printf '%s' "$name" | sed -E 's/ [0-9]+(\.[^ ]*)?$/\1/')"
  if [[ "$twin" != "$name" && -e "$dir/$twin" ]]; then
    rm -rf "$path"
    removed=$((removed + 1))
  fi
done < <(find "$OUT" -depth \( -name "* [0-9]" -o -name "* [0-9][0-9]" \
                              -o -name "* [0-9].*" -o -name "* [0-9][0-9].*" \) -print0)
echo "post-render: removed $removed sync-duplicate file(s) from $OUT"

# --- 2. Draft posts ----------------------------------------------------------
# Quarto replaces a draft's page with an empty stub and leaves it out of
# listings, search and feeds, but it still writes the draft's featured image
# and any PDF version next to the stub, where a guessed URL can reach them.
# Keep only the stub for posts marked `draft: true`.
pruned=0
for qmd in posts/*/index.qmd; do
  [[ -f "$qmd" ]] || continue
  # Look for `draft: true` inside the YAML front matter only (the block
  # between the first two `---` lines), not in the post body.
  if awk '/^---[[:space:]]*$/ { n++; next } n == 1' "$qmd" | grep -Eq '^draft:[[:space:]]*true[[:space:]]*$'; then
    out_dir="$OUT/$(dirname "$qmd")"
    if [[ -d "$out_dir" ]]; then
      while IFS= read -r -d '' extra; do
        rm -f "$extra"
        pruned=$((pruned + 1))
      done < <(find "$out_dir" -type f ! -name "index.html" -print0)
    fi
  fi
done
echo "post-render: removed $pruned leftover file(s) from draft post folders"

# --- 3. Sitemap --------------------------------------------------------------
SITEMAP="$OUT/sitemap.xml"
if [[ -f "$SITEMAP" ]]; then
  for page in styles.html thank-you.html 404.html; do
    # Drop the whole <url>...</url> entry whose <loc> ends in this page.
    perl -0pi -e "s{\s*<url>\s*<loc>[^<]*/\Q${page}\E</loc>.*?</url>}{}gs" "$SITEMAP"
  done
  echo "post-render: pruned utility pages from sitemap.xml"
fi
