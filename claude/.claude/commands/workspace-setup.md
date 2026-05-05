---
description: "Scaffold or edit local .claude/ config for the current repo: CLAUDE.md, settings, commands, agents, and hooks"
---

# Workspace Setup

Set up or update the local `.claude/` configuration for the current repository.

$ARGUMENTS

## What to do

1. **Assess current state** — check what `.claude/` files already exist in the working directory:
   - `CLAUDE.md` — project-level instructions
   - `.claude/settings.json` — local permissions, env vars, model overrides
   - `.claude/commands/` — project-specific slash commands
   - `.claude/agents/` — project-specific subagents
   - `.claude/hooks/` — event-driven shell hooks (PreToolUse, PostToolUse, etc.)

2. **Ask one focused question** if the user's intent is unclear — e.g., what stack/language the project uses, or which components they want to add.

3. **Create or edit** only what was requested (or what makes sense given the project context). Defaults to create if the file/dir doesn't exist.

### CLAUDE.md
Project-level instructions read at session start. Include: language/stack, coding conventions, test commands, lint commands, project-specific rules.

### .claude/settings.json
Local config (merged with user settings). Useful fields:
```json
{
  "permissions": {
    "allow": ["Bash(npm:*)", "Bash(pytest:*)"],
    "deny": []
  },
  "env": {
    "NODE_ENV": "development"
  }
}
```

### .claude/commands/<name>.md
Slash command frontmatter + body. `$ARGUMENTS` receives everything after the command name.
```markdown
---
description: "What this command does"
---
# Command Name
Do the following with $ARGUMENTS: ...
```

### .claude/agents/<name>.md
Subagent frontmatter + system prompt. Invokable via `Agent` tool or user mention.
```markdown
---
name: agent-name
description: "When to use this agent"
tools: Read, Write, Bash, Glob, Grep
model: sonnet
---
System prompt here...
```

### .claude/hooks/<name>.sh or <name>.py
Hooks fire on Claude Code events. Wire them up in `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command", "command": ".claude/hooks/pre-bash.sh" }] }],
    "PostToolUse": [...],
    "Stop": [...],
    "Notification": [...]
  }
}
```

4. **Write the files** using Write/Edit tools. Create parent directories as needed.

5. **Confirm** what was created/modified.
