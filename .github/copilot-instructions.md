# Global Copilot Instructions

## Approach
- Investigate before fixing: read the code, understand the context, then act
- Ask before guessing: if requirements are ambiguous, clarify rather than assume
- Explain non-obvious decisions in 1-2 sentences; skip explanations for obvious changes
- Lead with the answer or action, not the reasoning process

## Code Quality
- Follow SOLID principles: single responsibility, open/closed, Liskov substitution, interface segregation, dependency inversion
- Prefer simple, readable code over clever abstractions
- Don't add features, refactor code, or make "improvements" beyond what was asked
- Don't create helpers, utilities, or abstractions for one-time operations
- Three similar lines of code is better than a premature abstraction
- Only add comments where the logic isn't self-evident
- Don't add error handling for scenarios that can't happen — trust internal code and framework guarantees

## Security
- Never introduce injection vulnerabilities (SQL, command, XSS)
- Never commit secrets, API keys, or credentials
- Validate at system boundaries (user input, external APIs), not internally

## Git Conventions
- Use Conventional Commits: type(scope): description
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Keep subject line under 72 characters, use imperative mood
- Branch names: type/description (e.g., feat/user-auth, fix/login-timeout)

## Testing
- Write tests for new functionality and bug fixes
- Test behavior, not implementation details
- Use descriptive test names that explain what is being tested and expected outcome

## Documentation
- Update relevant docs when changing public APIs or behavior
- READMEs should explain what, why, and how to get started — not implementation details
