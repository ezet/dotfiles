# Unattended runs

Nobody is watching the board, so every pick has to reach a merged PR without
asking you anything.

## Screen — before step 5

Drop each candidate on the first test it fails; step 5 walks the survivors.

- **Decided** — the issue says what to do. A question of product behaviour,
  naming, UX or scope is yours, and an agent that answers it has invented a
  requirement. An issue too vague to judge fails here.
- **Self-verified** — done is something the agent runs: a test, a type check,
  a reproduction. Proof that needs a human eye on a screen, a device, a real
  payment or production data makes it attended work, however small.
- **Reachable** — everything it needs is in a repo the agent checks out. A
  third-party dashboard, a credential you hold, an app-store step or a deploy
  you trigger fails here.
- **Recoverable** — a wrong guess costs a reverted PR. Destructive migrations,
  auth, billing, and writes to production data are yours to watch.

Slots the survivors cannot fill stay empty. An empty slot costs nothing
overnight; an agent stalled on a question costs the slot and the night.

## Prompt — step 6

Add: a question that surfaces anyway — a review-gate `BLOCK` or a spent round
budget included, which `ship` would put to you — goes on the issue as a comment
saying what it blocks, and the agent exits.

## Report — step 7

Add every dropped candidate and the test it failed: the list waiting for you
when you are back.
