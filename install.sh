#!/usr/bin/env bash
# yourkit installer
#
# RECOMMENDED: don't pipe this to bash blindly. Instead:
#   git clone <this-repo-url>
#   cat install.sh          # read it — it's short
#   cd your-project && DEST=. bash /path/to/yourkit/install.sh
#
# If you do want the one-liner:
#   curl -fsSL <raw-url>/install.sh | bash
#   FORCE=1  ... | bash   # overwrite existing files instead of skipping
#   DEST=/path ... | bash # install elsewhere
#   REF=<tag-or-sha> ... | bash  # pin to a specific release instead of main
set -euo pipefail

REPO="${YOURKIT_REPO:-your-org/yourkit}"
REF="${REF:-main}"            # prefer pinning to a tagged release once you cut one
DEST="${DEST:-$PWD}"
FORCE="${FORCE:-0}"

echo "yourkit: installing into $DEST (ref: $REF)"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$REF" \
  | tar -xz --strip-components=1 -C "$TMP"

wrote=0
skipped=0

copy_file() {
  src=$1
  dst=$2
  if [ -e "$dst" ] && [ "$FORCE" != "1" ]; then
    echo "  skip (exists): $dst"
    skipped=$((skipped + 1))
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  case "$src" in *.sh) chmod +x "$dst" ;; esac
  echo "  wrote: $dst"
  wrote=$((wrote + 1))
}

copy_tree() {
  src_root=$1
  dst_root=$2
  [ -d "$src_root" ] || return 0
  while IFS= read -r f; do
    rel=${f#"$src_root"/}
    copy_file "$f" "$dst_root/$rel"
  done < <(find "$src_root" -type f)
}

copy_tree "$TMP/.claude" "$DEST/.claude"
copy_tree "$TMP/skills" "$DEST/.claude/skills"
for f in MEMORY.md; do
  [ -f "$TMP/$f" ] && copy_file "$TMP/$f" "$DEST/$f"
done

if [ -f "$DEST/.claude/CLAUDE.md" ]; then
  echo
  echo "  note: $DEST/.claude/CLAUDE.md is your always-loaded standing context."
  echo "        If you already have project-specific instructions, merge them in"
  echo "        rather than letting one silently overwrite the other."
fi

echo
echo "yourkit: install complete — $wrote files written, $skipped skipped"
echo "Nothing outside $DEST was touched. No network calls beyond the GitHub download above."
echo "Review $DEST/.claude/settings.json before your first session — it's the permission allowlist."
