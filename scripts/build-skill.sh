#!/usr/bin/env bash
# Bundle src/index.ts into a single Node-runnable ESM file at claude-skill/clarity.js.
# The result is checked into the repo so `curl`-installed skills work without a build step.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

OUT="skills/clarity/clarity.cjs"
echo "Bundling src/index.ts → $OUT …"
bunx esbuild src/index.ts \
  --bundle \
  --platform=node \
  --format=cjs \
  --target=node18 \
  --packages=bundle \
  --outfile="$OUT"

# Clean up legacy .js output if present
rm -f skills/clarity/clarity.js claude-skill/clarity.js claude-skill/clarity.cjs

chmod +x "$OUT"
echo "Done: $(wc -c < $OUT) bytes"
