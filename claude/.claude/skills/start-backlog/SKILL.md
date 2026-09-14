---
name: start-backlog
description: Start backlog issues as parallel herdr agents until X are in flight (default 10), picking work that cannot collide.
argument-hint: "[X] [--unattended] — keep X items in flight (default 10); --unattended picks only work that needs nothing from you"
disable-model-invocation: true
---

# Start backlog work

Board: **LKs agent project** — <https://github.com/orgs/hoopit/projects/2>.

Fill the board to **X in flight** — In progress plus In review, X defaulting to
**10** — one agent per issue, each on a **footprint** no other agent in flight
shares. Ten agents in one repo is normal; two in one file is a pile-up.

With `--unattended`, read [unattended.md](unattended.md) first: it adds a
screen to step 5, a line to each prompt, and a section to the report.

## 1. Require herdr

```bash
echo "${HERDR_ENV:-}"
```

The agents live in herdr tabs. Anything but `1` ends the run, said plainly.

## 2. Measure the deficit

```bash
hoopit-board slots <X>
```

Prints what is in flight, the deficit, the untriaged Backlog, and the rest
ranked Priority `P0`→`P3` then smallest Size — so a slot buys a finished PR
rather than a week of work. `hoopit-board --help` lists its other commands.

A deficit of zero or less completes the run: report what is in flight and
stop. Full is the board's resting state.

## 3. Triage the unranked

Set Priority and Size on each untriaged item — rubrics in `create-gh-issue` —
then rerun `slots` so they rank with the rest:

```bash
hoopit-board triage <repo> <n> --priority P2 --size M
```

## 4. Map the footprints in flight

```bash
hoopit-board footprint <repo>...
```

Lists every path an open PR touches. An in-flight item with no PR yet — and
every candidate, as step 5 reaches it — takes its footprint from the paths its
body names plus a grep for the symbols and endpoints it mentions. An issue too
vague to footprint owns its whole module.

A **collision** is a shared file, model or endpoint — or, in `hoopit/api`, two
items that each add a migration, which conflict on the migration graph however
far apart their files sit.

## 5. Pick

Walk the ranking. Take each candidate that collides with nothing in flight and
nothing already picked; pass over the rest. Stop at the deficit or the end of
the ranking.

Record each empty slot with the candidate that would have filled it and the
collision that blocked it. A colliding P0 stays on the board and heads that
record — it is the one thing here worth interrupting for.

## 6. Check, claim, dispatch

Per pick, in order:

1. `hoopit-board check <repo> <n>` — the ranking is minutes old. A non-zero
   exit names why the issue is no longer startable; drop it, and the next
   candidate that clears step 5 takes the slot.
2. `hoopit-board claim <repo> <n> --agent <name> --tab <label>`, before the
   agent exists. It moves the item to In progress and comments the agent and
   tab onto the issue — the marker later runs and `curate-backlog` read to see
   the issue is taken.
3. Dispatch through the `herdr` skill, in the workspace for the issue's repo
   and a tab named for the issue. After the `--`, pass `--model fable` for
   complicated work — Size `L`, a cause nobody has found, an approach still to
   decide, or a change across modules, migrations, concurrency or money; Size
   prices the fix, not the hunt — and `--model opus` for the rest.

The opening prompt carries:

- the repo and the issue URL;
- delivery through the `hoopit-dev:ship` skill, the issue as its `WORK_ITEM`;
- `closes #<n>` in the PR description;
- the paths the other agents own, to stay off;
- a **lead** where you have one — a file, a symbol, a log line to start from.

A lead points; the agent draws the conclusion. Anything that reads as a cause —
in the lead, or in the issue body, written from outside the code — travels as a
**guess** the agent owes a verdict on: name what would prove it wrong, go look
for that, and report it confirmed or replaced, in the PR when replaced. The
falsifier is what makes the verdict worth having; an agent asked to confirm a
guess confirms it.

## 7. Report

A table — issue, repo, Priority/Size, agent, model with its one-clause reason,
footprint — then the empty slots and what blocked each, then the in-flight
count before and after.
