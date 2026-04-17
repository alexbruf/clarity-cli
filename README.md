# clarity-cli

A CLI for Microsoft Clarity — query your analytics dashboard, list session recordings with playable URLs, find AI-referral traffic (ChatGPT, Perplexity, etc.), and search Clarity docs. Wraps the same endpoints as Microsoft's official MCP server, plus the public Data Export API. Ships with a Claude Code skill so you can ask questions naturally inside Claude.

Built with Bun, compiled to a standalone binary (no runtime required). Same shape as [`ics-cli`](https://github.com/alexbruf/ics-cli).

## Installation

### CLI — native binary (preferred)

Download from [Releases](../../releases):

```bash
# macOS (Apple Silicon)
curl -L https://github.com/alexbruf/clarity-cli/releases/latest/download/clarity-cli-darwin-arm64 \
  -o /usr/local/bin/clarity && chmod +x /usr/local/bin/clarity

# macOS (Intel)
curl -L https://github.com/alexbruf/clarity-cli/releases/latest/download/clarity-cli-darwin-x64 \
  -o /usr/local/bin/clarity && chmod +x /usr/local/bin/clarity

# Linux (x64)
curl -L https://github.com/alexbruf/clarity-cli/releases/latest/download/clarity-cli-linux-x64 \
  -o /usr/local/bin/clarity && chmod +x /usr/local/bin/clarity

# Linux (arm64)
curl -L https://github.com/alexbruf/clarity-cli/releases/latest/download/clarity-cli-linux-arm64 \
  -o /usr/local/bin/clarity && chmod +x /usr/local/bin/clarity
```

### CLI — from source

```bash
git clone https://github.com/alexbruf/clarity-cli && cd clarity-cli
bun install
bun run build     # produces ./clarity
```

### Get an API token

1. Open your Clarity project → **Settings → Data Export**.
2. Click **Generate new API token**, copy the value.
3. `clarity auth <your-token>` — stored at `~/.config/clarity-cli/config.json` (600 perms).

Or set `CLARITY_API_TOKEN` in your env, or pass `--token <token>` per command.

## Quick start

```bash
clarity auth <your-token>

# Natural-language dashboard query
clarity ask "top browsers last 3 days"
clarity ask "sessions with rage clicks on /checkout this week" --json

# Session recordings (response includes playable URLs)
clarity sessions --days 7 --rage-clicks --device Mobile -n 10 --json
clarity sessions --country "United States" --js-errors --json
clarity sessions --url-contains /pricing --min-duration 60 --sort SessionDuration_DESC

# AI-referral traffic (ChatGPT, Perplexity, Claude, Gemini, etc.)
clarity ai-traffic --days 30
clarity ai-sessions --days 7 -n 20 --json

# Search Clarity docs
clarity docs "how do I install Clarity on Shopify"

# Canned shortcuts
clarity top-pages --days 7 --device Mobile
clarity web-vitals --days 7
clarity errors --days 7
clarity traffic --days 7 --by Country

# Official public Data Export API (rate-limited: 10/day, 1-3 day lookback)
clarity insights --days 1 --dim1 OS --dim2 Country --json
```

## Claude Code skill

The skill at `claude-skill/SKILL.md` lets Claude call `clarity` on your behalf. It ships with a bundled `clarity.cjs` Node fallback so the skill works even if the native binary isn't on PATH.

### Install (user-level — recommended)

```bash
mkdir -p ~/.claude/skills/clarity
curl -L https://raw.githubusercontent.com/alexbruf/clarity-cli/main/claude-skill/SKILL.md   -o ~/.claude/skills/clarity/SKILL.md
curl -L https://raw.githubusercontent.com/alexbruf/clarity-cli/main/claude-skill/clarity.cjs -o ~/.claude/skills/clarity/clarity.cjs
```

### Install (project-level)

```bash
mkdir -p .claude/skills/clarity
curl -L https://raw.githubusercontent.com/alexbruf/clarity-cli/main/claude-skill/SKILL.md   -o .claude/skills/clarity/SKILL.md
curl -L https://raw.githubusercontent.com/alexbruf/clarity-cli/main/claude-skill/clarity.cjs -o .claude/skills/clarity/clarity.cjs
```

### Install (clone)

```bash
git clone https://github.com/alexbruf/clarity-cli /tmp/clarity-cli
cp -r /tmp/clarity-cli/claude-skill ~/.claude/skills/clarity
```

Both paths read the same `~/.config/clarity-cli/config.json` token, so a single `clarity auth <token>` configures both the CLI and the skill.

Once installed, ask Claude things like:

> "What were my rage-click sessions on /checkout this week?"
> "How much traffic did I get from ChatGPT last month?"
> "Show me Core Web Vitals for mobile users"
> "How do I enable masking in Clarity?"

## Capabilities

| Want to… | Command | Backend |
|---|---|---|
| Ask anything on the dashboard in English | `ask` | MCP `/dashboard/query` |
| List session recordings with filters + URLs | `sessions` | MCP `/recordings/sample` |
| Find AI-referral traffic/sessions | `ai-traffic`, `ai-sessions` | (built on `ask`, `sessions`) |
| Search Clarity docs | `docs` | MCP `/documentation/query` |
| Aggregate export (rate-limited) | `insights` | Public `export-data/api/v1` |

### Not available (no public API)

- Heatmap images / raw click coordinates (but `ask` answers heatmap-adjacent questions like "where do mobile users stop scrolling on /pricing?")
- Funnel / segment / smart-event CRUD — read-only via `ask`
- Live (in-progress) session recordings
- Clarity Copilot chat

## Commands

Run `clarity --help` or `clarity <command> --help` for full option listings. Summary:

```
clarity auth <token>               Save API token
clarity auth --show                Show masked token
clarity auth --clear               Remove token

clarity ask <question>             NL dashboard query
clarity sessions [filters]         List session recordings
clarity docs <question>            Search Clarity documentation
clarity insights --days 1|2|3      Official Data Export API (10/day)

clarity ai-traffic [--paid]        AI-referral traffic summary
clarity ai-sessions [--paid]       AI-referral session recordings
clarity top-pages                  Top pages shortcut
clarity web-vitals                 Core Web Vitals shortcut
clarity errors                     Top JS errors shortcut
clarity traffic --by <dim>         Traffic breakdown shortcut
```

Every data command supports `--json` for machine-readable output and `--token <t>` for per-invocation overrides.

## Configuration

- **Token:** `~/.config/clarity-cli/config.json` (set via `clarity auth`, env `CLARITY_API_TOKEN`, or `--token`)
- **Priority:** CLI flag > env var > config file

No other configuration — the token is the only secret.

## License

MIT
