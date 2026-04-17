---
name: clarity
description: Query Microsoft Clarity for UX signals (rage clicks, dead clicks, quick-back clicks, excessive scroll, JS errors, scroll depth) and find relevant session recordings with playable replay URLs. Use when the user asks about their Clarity project, session replays, session recordings, user frustration signals, where users are struggling on the site, or wants to watch sessions matching specific behaviors.
allowed-tools: Bash(clarity *), Bash(node *), Bash(curl *), Bash(mkdir *), Bash(chmod *), Bash(command *), Bash(ls *), Bash(uname *)
---

# Clarity — session replays & UX signals

Find session recordings and UX-pain signals in Microsoft Clarity. Optimized for "where are users struggling and can I watch it happen".

## Setup (first run)

Detect what's available:
```bash
command -v clarity || ls "$CLAUDE_SKILL_DIR/clarity.cjs" 2>/dev/null
```

### If neither exists — install one

**Preferred: native binary** (fast, no Node needed). Pick the asset matching the user's platform (`uname -sm`):

```bash
# macOS arm64
curl -L https://github.com/alexbruf/clarity-cli/releases/latest/download/clarity-cli-darwin-arm64 \
  -o /usr/local/bin/clarity && chmod +x /usr/local/bin/clarity

# macOS x64
curl -L https://github.com/alexbruf/clarity-cli/releases/latest/download/clarity-cli-darwin-x64 \
  -o /usr/local/bin/clarity && chmod +x /usr/local/bin/clarity

# Linux x64
curl -L https://github.com/alexbruf/clarity-cli/releases/latest/download/clarity-cli-linux-x64 \
  -o /usr/local/bin/clarity && chmod +x /usr/local/bin/clarity

# Linux arm64
curl -L https://github.com/alexbruf/clarity-cli/releases/latest/download/clarity-cli-linux-arm64 \
  -o /usr/local/bin/clarity && chmod +x /usr/local/bin/clarity
```

**Fallback: Node.js bundle** into the skill directory (no PATH install needed):
```bash
mkdir -p "$CLAUDE_SKILL_DIR"
curl -L https://raw.githubusercontent.com/alexbruf/clarity-cli/main/claude-skill/clarity.cjs \
  -o "$CLAUDE_SKILL_DIR/clarity.cjs"
```

### Pick the binary to use in every command

```bash
if command -v clarity >/dev/null 2>&1; then CLARITY=clarity
else CLARITY="node $CLAUDE_SKILL_DIR/clarity.cjs"
fi
```

### Auth (once per user)

```bash
$CLARITY auth --show
```

If no token is configured, ask the user for their Clarity API token (from **Clarity project → Settings → Data Export → Generate new API token**) and save it:
```bash
$CLARITY auth <token>
```

## Output formats

Every data command supports three output modes. **Default is a compact text table** — prefer it for display; JSON wastes tokens.

| Flag | When to use |
|---|---|
| *(default)* | Displaying results to the user. Tables where shape allows, prose otherwise. |
| `--csv` | Piping to another tool or when the user wants a spreadsheet-ready export. |
| `--json` | Only when you need specific nested fields the default formatting dropped, or for programmatic parsing of session URLs etc. |

## Primary use cases

### "Show me sessions where users are struggling"

```bash
$CLARITY sessions --days 7 --rage-clicks -n 10
$CLARITY sessions --days 7 --dead-clicks -n 10
$CLARITY sessions --days 7 --quickback-clicks -n 10
$CLARITY sessions --days 7 --excessive-scroll -n 10
$CLARITY sessions --days 7 --js-errors -n 10
```

Combine filters — e.g., rage clicks on a specific page on mobile:
```bash
$CLARITY sessions --days 7 --rage-clicks --device Mobile --url-contains /checkout -n 10
```

### "Watch specific session recordings"

The response for `sessions` includes playable URLs on `clarity.microsoft.com`. Surface the top 3–5 URLs directly to the user so they can click through:
```bash
$CLARITY sessions --days 7 --rage-clicks --url-contains /checkout -n 5 --json
# Pull the replay URLs out of the JSON and present them as a numbered list.
```

Use `--json` here (not the default table) when you need the exact replay URL field for presentation.

### "Which pages frustrate users the most?"

```bash
$CLARITY ask "Top pages with most rage clicks in the last 7 days"
$CLARITY ask "Top pages with dead clicks in the last 7 days"
$CLARITY errors --days 7
```

## Full command reference

| Command | Purpose |
|---|---|
| `$CLARITY sessions [filters] -n N` | List session recordings with replay URLs |
| `$CLARITY ask "<NL question>"` | Natural-language dashboard query |
| `$CLARITY docs "<question>"` | Search Clarity documentation |
| `$CLARITY top-pages [--device D] --days N` | Top pages by views |
| `$CLARITY web-vitals --days N` | Core Web Vitals summary |
| `$CLARITY errors --days N` | Top JS errors |
| `$CLARITY traffic --by <dim> --days N` | Traffic breakdown |
| `$CLARITY ai-sessions --days N` | Sessions from AI-referral channels |
| `$CLARITY ai-traffic --days N` | AI-referral traffic summary |
| `$CLARITY insights --days 1\|2\|3 --dim1 … --json` | Official public export (10/day cap) |

## Session filter options

```
--days N                         # lookback, default 3
--from YYYY-MM-DD --to YYYY-MM-DD
--url-contains STR               # URL visited during session
--entry-url STR / --exit-url STR
--device Mobile|Tablet|PC        # repeatable
--browser Chrome|Safari|…        # repeatable
--os Windows|MacOS|iOS|Android|…
--country "United States"        # repeatable
--user-type new|returning
--intent low|medium|high
--channel AITools|OrganicSearch|Social|PaidSearch|…
--rage-clicks | --dead-clicks | --quickback-clicks | --excessive-scroll
--js-errors | --click-errors
--smart-event Purchase|SignUp|AddToCart|…
--min-duration SEC / --max-duration SEC
--min-scroll PCT / --max-scroll PCT
--sort SessionStart_DESC | SessionDuration_DESC | SessionClickCount_DESC | PageCount_DESC
-n, --count N                    # 1-250, default 100
```

## Tips

- **Always include a time range** in `ask`/`docs` queries. If the user didn't specify one, ask.
- **Keep `ask` queries single-purpose.** "Top browsers last 3 days" works; "all analytics for everything" doesn't.
- **Prefer `ask` over `insights`** — `insights` is capped at 10 requests per project per day.
- **Session URLs are the point.** When the user asks to "see" or "watch" sessions, surface the replay URLs from the JSON response.
- **For "how do I X in Clarity" questions**, run `$CLARITY docs "X"` before answering from general knowledge.
