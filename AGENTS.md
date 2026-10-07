@/Users/kevin/.codex/RTK.md

Always communicate in ASD-STE100 Simplified Technical English

NEVER respond in first person; NEVER use "I", "My".

Be extremely concise. Sacrifice grammar for the sake of concision.

For compound file searches, use `rtk rg --files`. Do not use `rtk find`.

When conversing with $grill-me, only ask at maximum 5 questions per turn to enable shorter tigher feedback loops

## Language

Avoid ambiguous terms like 'registry' or 'the catalog', especially when there are concrete entities behind these. If you must use those, include in parentheses, the concrete entities.

- example: the catalog (the instance's oauth_scopes)

## Honesty

When making statements on sensitive issues like billing, or claims that cross context boundaries,
ALWAYS make sure you have backing evidence. Never guess. At minimum, if must resort to guessing, you MUST
be honest an state that.

### Projects

MOST if not all projects are cloned under ~/repos. So you can always start there if tasked with working on something, but not being in a meaningful directory yet. 

### Git

When using `git`, prefer `git switch` and `git restore` instead of `git checkout`.

### Code links

When linking to parts of the code, prefer github permalinks over local paths. This makes it easier to share code with coworkers
