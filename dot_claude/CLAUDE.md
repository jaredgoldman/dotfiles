# User Preferences

## Environment
- Arch Linux with omarchy (Hyprland-based desktop)
- Editor: Neovim
- Primary language: TypeScript

## Working Principles
- Always keep the project context and documentation top of mind. Read CLAUDE.md files, READMEs, and relevant docs before diving into implementation.
- Prefer abstracted and integrated patterns over quick one-off solutions. If existing abstractions need to be extended or refactored to support new functionality, that is the right approach — do the refactor rather than working around it.
- When uncertain about an approach, architecture, or requirement, raise it before implementing. Do not guess or build around ambiguity.
- Proactively look things up via web search or web fetch when it would help — documentation, API references, error messages, etc. Do not hesitate to research.
- When creating Jira tickets, always present the full ticket content (summary, description, type, etc.) in a human-readable format for review before posting to Jira.

## Testing
- Always write tests for net-new code.
- Scope test runs to the affected packages only — do not run the full test suite unless explicitly asked.

## Monorepo
- Respect package boundaries. Do not reach across packages or import internals from sibling packages.
- When functionality is needed by multiple packages, consider whether it should be abstracted into a shared package.

## Git
- Do not create commits, amend commits, or manage branches. The user manages git themselves.

## Planning
- For non-trivial or multi-step implementations, always create a plan first. Tell the user where the plan file is stored so they can review it.
