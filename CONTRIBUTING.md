# Contributing to Waycore

Thanks for your interest in contributing! This project follows a simulation-first approach: develop on a laptop using Docker Compose and mocked hardware before touching real devices.

## Ground Rules
- Keep PRs small and focused. Link issues using “Closes #ID”.
- Favor clarity and reliability over cleverness; readability wins.
- Align with MVP scope in `docs/overview.md`. Non-MVP features may be deferred or moved to external modules.
- Security and privacy considerations are required for features touching data, radios, or networking.

## Development Workflow
1. Fork and create a feature branch:
   - Branch naming: `feat/*`, `fix/*`, `chore/*`, `docs/*`, `refactor/*`
2. Follow Conventional Commits:
   - `feat: add module manager discovery`
   - `fix: handle GPS timeout edge case`
   - `docs: expand architecture rationale`
   - `refactor: extract TAK bridge`
3. Write tests where applicable and update docs.
4. Open a PR using the provided template.

## Directory Layout
See the top-level `README.md` and `docs/overview.md`. Code and service boundaries should reflect the processes listed there.

## Building Apps

If you're building apps for Waycore, see the developer documentation:

- [App Development Guide](docs/developer/app-development-guide.md) — Complete guide to building apps
- [App Manifest Schema](docs/developer/app-manifest.md) — Configuration reference
- [App Backend Integration](docs/developer/app-backend.md) — Python backend services
- [UI Components](docs/developer/ui-components.md) — Component library and theme

## Code Style
- Python: typed where practical, clear names, prefer early returns
- UI (Qt/QML + PySide6): keep logic minimal in QML, move complexity to Python
- Comments are for non-obvious rationale and invariants only
- Avoid deep nesting and broad try/catch blocks

## Security
Report vulnerabilities per `SECURITY.md`. Do not open public issues for sensitive findings.

## Community Standards
Be respectful and constructive. See `CODE_OF_CONDUCT.md`.
