---
name: resource-staleness-report
description: "Generate or refine periodic staleness reporting for Copilot resources"
agent: "GitHub Actions Expert"
argument-hint: "Staleness thresholds and reporting preferences"
---

# Resource Staleness Report

Preferred custom agent: GitHub Actions Expert.

Set up or improve staleness reporting for Copilot resource files:

${input:scope:Provide threshold preferences, directories, and reporting cadence}

Requirements:

- Use the resource-staleness-report workflow baseline.
- Classify resources into stale, aging, and fresh buckets using commit history.
- Produce concise report output that is easy to triage.
- Keep report noise low while ensuring aging resources are visible.

Output format:

1. Scope and thresholds
2. Classification logic
3. Issue/report format
4. Scheduling and automation details
5. Maintenance checklist
