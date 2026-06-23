# Prose Linting Tools

## Vale

Vale is a standalone Go binary that applies YAML-defined style rules to prose in Markdown, AsciiDoc, HTML, reStructuredText, and other formats. It is markup-aware: code blocks, inline code, and front matter are excluded from checks by default.

Vale ships with a minimal built-in `Vale` style. All other styles (Google, Microsoft, write-good, proselint) are installable packages fetched via `vale sync`.

### Config (.vale.ini)

```ini
StylesPath = .vale/styles
MinAlertLevel = suggestion

[*.md]
BasedOnStyles = Vale, MyStyle
```

### Custom rule types

| Type | Use case | Key field |
|---|---|---|
| `existence` | Flag forbidden patterns | `tokens` (word list) or `raw` (regex) |
| `substitution` | Enforce preferred terms | `swap: {bad: good}` |
| `occurrence` | Limit pattern frequency | `max: N` |

### What Vale can check (focus areas)

- **Em dashes**: use `raw` with a Unicode escape to avoid embedding the glyph in the rule file.
- **Filler words**: `existence` rule with `tokens` list.
- **Banned vocabulary**: `existence` or `substitution` depending on whether you want a replacement suggested.
- **Transition-word overuse**: `occurrence` rule with `max: 1` or `max: 2` per file.

### Example: filler words + em dash rule

```yaml
extends: existence
message: "Avoid '%s' in prose."
level: warning
ignorecase: true
tokens:
  - just
  - simply
  - essentially
  - basically
  - delve
  - leverage
  - robust
  - seamless
raw:
  - '\x{2014}'
```

### Shell integration

```sh
# Exit 1 on any errors (good for CI)
vale --output=JSON docs/ | jq '.[]'

# Suppress non-zero exit (report only)
vale --no-exit --output=line docs/
```

Exit codes: `0` = clean, `1` = lint errors found, `2` = runtime error.

---

## Alternative tools

| Tool | Language | Markup-aware | Extensible | Notes |
|---|---|---|---|---|
| write-good | Node | No | No | Passive voice, weasel words; also a Vale package |
| textlint | Node | Yes | Plugin-based | Aggregates other linters; slower than Vale |
| proselint | Python | No | No | Opinionated, curated rules; no Markdown support |

Vale is the strongest choice for Markdown CI integration: single binary, no runtime dependencies, structured JSON output, per-file and per-rule suppression, and the fastest benchmark of the group.
