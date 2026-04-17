# clarity-cli

CLI for Microsoft Clarity. Wraps MCP `/dashboard/query`, `/recordings/sample`, `/documentation/query`, and the public `export-data/api/v1` endpoint. Built with Bun, compiled to a single binary. Ships a Claude Code skill with a Node.js fallback bundle.

## Setup

```
bun install
```

## Usage (dev)

```
bun run src/index.ts auth <token>
bun run src/index.ts ask "top browsers last 3 days"
bun run src/index.ts sessions --days 7 --rage-clicks --json
bun run src/index.ts ai-traffic --days 30
bun run src/index.ts docs "how to install on Shopify"
```

## Build

```
bun run build            # compiled binary → ./clarity
bun run build:skill      # Node fallback → claude-skill/clarity.cjs (checked in)
```

Release workflow triggers on `v*` tags and produces both the 4-platform binary matrix and the regenerated skill bundle.

## Architecture

Single-package CLI. Commander-based. Config at `~/.config/clarity-cli/config.json`.

| File | Responsibility |
|---|---|
| `src/index.ts` | Commander wiring for all commands |
| `src/api.ts` | 4 endpoint wrappers, bearer auth |
| `src/filters.ts` | Map CLI flags → MCP `FiltersType` payload |
| `src/config.ts` | Token store (JSON file, 600 perms) |
| `src/formatter.ts` | Text (unwrap MCP envelope) + JSON output |
| `src/types.ts` | TS unions mirroring the MCP Zod schema |

## Claude skill

`skills/clarity/SKILL.md` + `skills/clarity/clarity.cjs`. The skill prefers `clarity` on PATH and falls back to `node $CLAUDE_SKILL_DIR/clarity.cjs`. Install docs in README.

## AI visibility

Clarity's `channel` taxonomy includes `AITools` and `PaidAITools`, covering ChatGPT, Perplexity, Claude, Gemini, etc. Surfaced as first-class `ai-traffic` / `ai-sessions` commands; also accessible via `--channel AITools` on `sessions` or free-form `ask`.

## Rate limits

- MCP endpoints (`ask`, `sessions`, `docs`): unlimited.
- Public `insights` endpoint: **10 requests per project per day**, 1-3 day lookback only. Prefer `ask` unless the user specifically needs the aggregate format.
