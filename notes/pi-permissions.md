# pi permissions / auto mode (researched, NOT installed)

Date: 2026-11-20. Goal: a Claude Code style "auto mode" where an LLM classifier
reviews tool calls (mainly `bash`) and auto-approves safe ones.
Source: read-only audit of npm tarballs by a sub-agent. Nothing was run, so
compat with pi 1.5.2 and latency figures are unverified.

## Recommendation (when we decide to install)

`@gotgenes/pi-permission-system` (rules) + `@mzwing/pi-permission-auto-review`
(LLM classifier), `claude-code` preset, cheaper model, versions pinned in nix,
review the diff on every bump, `promptTimeoutMs` set (e.g. 120000).

## Candidates

| Package | Version | LLM classifier? | Verdict |
|---|---|---|---|
| `@gotgenes/pi-permission-system` | 42.2.0 | No (rules only) | Good base layer. 282 stars, active, tree-sitter bash AST, fails closed. |
| `@mzwing/pi-permission-auto-review` | 1.0.2 | **Yes** | The classifier. Needs the one above. 4 stars, single maintainer, created 2026-07. Code clean (~2,950 lines). |
| `auto-permission-system` | 6.1.1 | **No** | Skip. "Auto mode" just means fail-closed when headless. OS sandbox + regex rules, 1 star, takes over bash execution. |
| `pi-permission-ai-guard` | 0.15.0 | Yes | Skip. Peer pins `@gotgenes` >=40 <41, incompatible with 42.x. |

## How `@gotgenes` works

- allow / ask / deny rules across `bash`, `read`, `write`, `path`,
  `external_directory`, `mcp`, `skill`.
- Bash parsed with tree-sitter; wrappers and unparseable commands resolve to `ask`.
- `authorizerChain`: when a call lands on `ask`, registered links are consulted
  before the human prompt. Config must contain `"authorizerChain": ["auto-review"]`.
- Config: `~/.pi/agent/extensions/pi-permission-system/config.json` (global),
  `<cwd>/.pi/extensions/pi-permission-system/config.json` (project, trust-gated).
  Schema in `schemas/permissions.schema.json`. Machine-local approvals go to
  `config.local.json`. Check it never writes back to the global file (nix store is read-only).
- Allow in-project reads/edits in the rules so they skip the reviewer.

## How `@mzwing` works

- Each `ask` goes to an LLM: allow / deny(+reason) / defer. Defer (API failure,
  timeout, bad reply, denial limit) falls through to the human prompt.
- Presets: `claude-code` = Claude Code's 2-stage check (fast stage with reasoning
  off, escalates to a thinking stage if it blocks; 3 consecutive / 20 total
  denials -> human). `codex` (default) = single call, Codex Guardian policy.
- Model: via pi's model registry and existing logins, no own keys. Defaults
  `anthropic/claude-sonnet-5` (claude-code); `provider`/`model` overridable.
- Sent to the reviewer's provider: tool call + args every time; a trimmed
  transcript (claude-code: user msgs, assistant text, tool-call inputs, results
  reduced to ok/error; codex also sends tool-result text); context files such as
  AGENTS.md (claude-code).
- Latency est. 1-3s when the fast stage allows (not measured). Follow-up reviews
  reuse the conversation so prompt caching helps.
- Config: `~/.pi/agent/extensions/pi-permission-auto-review/config.json`
  (+ trust-gated project one), schema `schemas/config.schema.json`. The
  `/permission-auto-review` command rewrites the file, which conflicts with a
  read-only nix file. Invalid config disables auto decisions.
- No postinstall, no child_process / eval / fetch. Engines: node >= 24 (check nix node).

## Cautions

- An LLM reviewer is not a security boundary. It only sees what the transcript shows.
- Command and transcript go to the reviewer's model provider.
- pi-roost children are full pty pi processes, each loading its own copy of the
  extension. An unanswered dialog in a child waits forever unless
  `promptTimeoutMs` is set (it then denies).
- Third-party links in the chain run with your privileges. `@gotgenes` itself
  says to review them before use.
