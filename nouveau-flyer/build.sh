#!/bin/sh
# Régénère les PDF des flyers depuis les sources HTML.
# Même pipeline que les PDF d'origine : Chrome headless → A4, marges gérées par @page.
#   ./build.sh            → les deux flyers
#   ./build.sh moto       → moto seulement
#   ./build.sh auto out/  → auto, dans le dossier out/
set -eu
cd "$(dirname "$0")"

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
[ -x "$CHROME" ] || { echo "Chrome introuvable : $CHROME (surcharger avec CHROME=...)" >&2; exit 1; }

which="${1:-tous}"
outdir="${2:-.}"
mkdir -p "$outdir"

build() {
  src="flyer-$1.html"
  dst="$outdir/Govo-Permis-$2.pdf"
  [ -f "$src" ] || { echo "Source manquante : $src" >&2; return 1; }
  "$CHROME" --headless --disable-gpu --no-pdf-header-footer \
    --virtual-time-budget=20000 \
    --print-to-pdf="$dst" "file://$PWD/$src" 2>/dev/null
  echo "✓ $dst ($(pdfinfo "$dst" 2>/dev/null | awk '/^Pages:/{print $2" pages"}'))"
}

case "$which" in
  moto) build moto Moto ;;
  auto) build auto Auto ;;
  *)    build auto Auto; build moto Moto ;;
esac
