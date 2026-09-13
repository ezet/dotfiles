---
name: create-gh-issue
description: File a triaged GitHub issue. Use when filing an issue, TODO, follow-up or finding for Hoopit agent work.
---

# Create a GitHub issue

An issue is filed only once it is **triaged**: assigned, typed, prioritised,
sized. Type says what kind of work it is; Priority and Size are what the board
sorts on, so a blank one hands the triage straight back to a human. Untriaged is
unfinished.

Board: **LKs agent project** — <https://github.com/orgs/hoopit/projects/2>.
Status belongs to the board's add-workflow; leave it where it lands.

## 1. Resolve the repo

```bash
gh repo view --json nameWithOwner -q .nameWithOwner
```

The current repo, unless the request names another. With no repo either way,
ask whether it belongs in `hoopit/api`, `hoopit/web-admin` or
`hoopit/flutter-app`.

## 2. Search the board first

An open issue may already cover this, or the finding may belong on a related
issue as a comment.

```bash
hoopit-board open
```

Every open item on the board, one line each — `hoopit-board` (in
`~/.local/bin`) is the board's mechanical half.

Read every plausible match before creating anything — `gh api
repos/<repo>/issues/<n> --jq '{number, title, state, body}'`, which is REST where
`gh issue view` would be GraphQL. The step ends with a covering issue named, or
with none found.

## 3. Write it

- **Title** — imperative, prefixed with the area where the repo uses one:
  `ci: cache CocoaPods between deploys`.
- **Body** — the symptom or the want, why it matters, and one concrete
  acceptance line. Point at the code (`path/to/file.py:120`), the failing run,
  the Sentry issue.

## 4. File it, assigned and typed

Write the body to a scratchpad file, then:

```bash
gh issue create --repo <repo> --assignee @me --type <Type> \
  --title '<title>' --body-file <path>
gh project item-add 2 --owner hoopit --url <issue-url>
```

**Type**

| | |
|---|---|
| `Bug` | An unexpected problem or behaviour. Something is broken. |
| `Feature` | A request, an idea, new functionality. |
| `Task` | Default. A specific piece of work that is neither of the above — a refactor, a chore, a cleanup, a spike. |
| `Follow-up` | Work a **parent** issue is not complete without: logs to read once it ships, a script to run, errors to check, something to monitor. |

A parent to name makes it a `Follow-up` — name it in the body (`follows
hoopit/api#412`). No parent makes it a `Task`.

## 5. Set Priority and Size

Read both off the issue's own content and set them — state each value and a
one-clause reason in your reply, then keep going.

```bash
hoopit-board triage <repo> <n> --priority P2 --size M
```

One call sets both fields.

**Priority**

| | |
|---|---|
| `P0` | Broken in production, or blocking work happening right now. Data loss, a failing deploy, users hitting it. |
| `P1` | Real bug with a workaround, or work that unblocks something scheduled. |
| `P2` | Default. Worth doing, no deadline attached. |
| `P3` | Fine if it sits. Polish, speculative cleanup. |

Torn between two levels, take the lower — except a production symptom, which
floors at `P1`.

**Size**

| | |
|---|---|
| `XS` | Minutes. One line, one config value, a typo. |
| `S` | An hour or two. One file, no design decisions. |
| `M` | Default for a real change. A few files, a test, some thinking. |
| `L` | Multi-day, or cross-cutting enough that the approach needs deciding first. |
| `XL` | Too big for one PR — say so, and offer to split it. |

Size the fix, not the investigation.

## 6. Report

The issue URL, the Type, the Priority and the Size, so a wrong call is one
glance from being corrected.
