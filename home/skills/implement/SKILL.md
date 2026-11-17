---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

If the user passes a ticket reference, fetch it from the issue tracker, assign yourself to it, and state its title before starting. If the reference is ambiguous, ask.

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

If the work touches the UI verify it using the playwrite or chrome mcp, or, if there are custom skills for this in the repo, use those.

Once done, call the Skill tool with "code-review" to review the work.

Run any handover check skills available in the repo.

Commit your work to the current branch.
