---
name: start-backlog
description: Start backlog issues as parallel herdr agents until X are in flight (default 10), picking work that cannot collide.
argument-hint: "X — how many items to keep in flight (default 10)"
disable-model-invocation: true
---

# Start backlog work

Board: **LKs agent project** — <https://github.com/orgs/hoopit/projects/2>.

Fill the board up to **X in flight** — In progress plus In review — where X is
this skill's argument, default **10**. Each started issue gets its own agent
and a **footprint** no other agent in flight shares. Ten agents in one repo is
normal here; ten agents editing one file is a pile-up.

## 1. Require a herdr session

```bash
echo "${HERDR_ENV:-}"
```

The agents live in herdr tabs, so a session outside one has nowhere to put
them: anything but `1` here ends the run, with that said plainly.

## 2. Measure the deficit

```bash
hoopit-board slots <X>
```

`hoopit-board` (in `~/.local/bin`) is the board's mechanical half — fetching,
filtering, ranking, freshness gates and bulk writes; `--help` lists the rest. `slots` prints the in-flight count against X,
the deficit, the Backlog items too untriaged to rank, and the rest ranked
Priority `P0`→`P3` then smallest Size first, so a slot buys a finished PR
rather than a week of work.

A deficit of zero or less **completes** the run: report what is in flight and
stop. A full board is the expected state, not a problem to solve by starting
something anyway.

## 3. Footprint the work in flight

```bash
hoopit-board footprint <repo>...
```

One line per path an open PR is touching, and which PRs touch it — the map the
picks have to stay off. An in-flight item with no PR yet leaves no trace here,
so take its footprint from the paths its issue body names.

## 4. Triage what the ranking left out

An item with no Priority or Size cannot be ranked, which is why `slots` lists
those separately. Set them — the rubrics are in the `create-gh-issue` skill —
and the next `slots` run ranks them with the rest:

```bash
hoopit-board triage <repo> <n> --priority P2 --size M
```

## 5. Footprint each candidate

From the paths its body names, plus a grep for the symbols and endpoints it
mentions. An issue too vague to footprint owns its whole module: assume wide
and let it collide.

## 6. Fill the slots

Walk the ranking and take each candidate whose footprint is disjoint from every
in-flight footprint and every candidate already picked. On a collision, skip it
and continue down the ranking. Stop at the deficit, or when the ranking runs
out.

A collision is a shared file, a shared model, a shared endpoint — or, in
`hoopit/api`, two candidates that both add a migration, which conflict on the
migration graph however far apart their files sit.

Every slot left empty is reported with the item that would have filled it and
the collision that blocked it. A P0 that collides stays on the board and goes
in that report — it is the one thing here worth interrupting for.

## 7. Check, claim, then dispatch

The board dump is minutes old by now and a claim is a write, so confirm each
pick is still startable:

```bash
hoopit-board check <repo> <n>
```

It exits non-zero, naming the reason, on an issue that is closed, one a PR
already claims to close, one blocked by another, or one a previous run already
started. A `SKIP` drops the candidate and the next one down the ranking takes
the slot.

Then claim it, before the agent exists. The board is how a second agent sees
that an issue is taken, so a claim landing after the agent starts is a claim
landing too late.

```bash
hoopit-board claim <repo> <n> --agent <name> --tab <label>
```

That moves the item to In progress and comments the agent and tab onto the
issue — the marker `check` reads on later runs, and the one `curate-backlog`
reads to tell an abandoned item from a busy one.

Then dispatch through the `herdr` skill — one agent per issue, in the workspace
for that issue's repo, in its own tab named for the issue. These agents run on
Fable: pass `--model fable` among the native arguments after the `--`.

Each agent's opening prompt carries four things:

- the repo and the issue URL, to read for itself;
- a fresh worktree of its own, so ten agents never share a checkout;
- `closes #<n>` in the PR description;
- the paths the other agents in flight own, to stay clear of.

Add a **lead** where you have one — a file, a symbol, a failing log line worth
starting from. A lead points; it does not conclude. Anything that reads as a
cause travels marked as a guess, and the agent owes a verdict on it: name what
would prove the guess wrong, go look for that, then report it confirmed or
replaced by what was actually wrong. The falsifier is what makes the verdict
worth having — an agent asked to confirm a guess confirms it, and a wrong
premise comes back wearing a second signature.

The issue body is a guess by the same standard, written from outside the code.
It gets the same falsifier before any fix is written, and the PR says so when
the real cause turned out to be different.

## 8. Report

A table — issue, repo, Priority/Size, agent name, footprint — then the empty
slots and what blocked each. Finish with the in-flight count, before and after.
