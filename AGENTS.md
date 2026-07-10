# pwsh-env Agent Guide

## Project Overview

`pwsh-env` is a personal environment repository for PowerShell Core (pwsh).  
It is loaded from the user's `$PROFILE` via `init.ps1`.

## Repository Structure

| Path | Purpose |
|------|---------|
| `init.ps1` | Entry point. Loaded from `$PROFILE`. |
| `func.ps1` | Shared helper functions, lazy completer registry, and deferred prompt hook. |
| `init.d/*.ps1` | Per-tool initialization scripts (aliases, env vars, completers, deferred hooks). |
| `alias.d/*.ps1` | Additional alias definitions. |
| `cmdlet.d/*.ps1` | Custom cmdlets. |
| `completion.d/*.ps1` | Static completion scripts. |
| `bins/` | Extra binary directories appended to `PATH`. |
| `install-deps.ps1` | Installs required PowerShell modules. |
| `Taskfile.yaml` | Task runner definitions for setup and updates. |

## Loading Strategy

`init.ps1` loads scripts in this order:

1. `func.ps1`
2. `.env.ps1` (if present, git-ignored)
3. `PATH` setup (`~\bin`, `.path`, `bins/*`)
4. `cmdlet.d/*.ps1`
5. `init.d/*.ps1` (concatenated into a single scriptblock for speed)
6. `completion.d/*.ps1`
7. `alias.d/*.ps1`

Each file is read with `Get-Content -Raw` and executed via `[scriptblock]::Create(...)` for performance.

## Key Functions in `func.ps1`

- `Test-Command $Name` — fast command existence check.
- `Register-LazyArgumentCompleter -CommandName $Name -Generator $ScriptBlock` — registers a native completer that is generated on first use.
- `Register-DeferredPromptHook -Action $ScriptBlock` — defers heavy initialization (e.g. `mise activate`, `git-completion`) until the first prompt render.

## User Preferences

- **Maintainability over micro-optimization**: prefer separate files in `init.d/` rather than monolithic `_misc.ps1` / `_deferred.ps1` files.
- **Lazy / deferred initialization**: avoid paying startup cost for tools that are not used in every session.
- **Prompt**: rendered by `starship`.
- **Version manager**: `mise` is activated via deferred prompt hook.
- **Language**: commit messages are written in Japanese.

## Coding Conventions

- Use `Test-Command` before registering tool-specific completers or aliases when the command is required for the feature to work.
- Prefer `if (Test-Command ...) { ... }` over `if (-not (Test-Command ...)) { return }` in `init.d/*.ps1`, because files are concatenated into one scriptblock at load time.
- Keep per-tool logic in its own `init.d/<tool>.ps1` file.
- Register heavy native completers via `Register-LazyArgumentCompleter`.
- Register heavy shell integrations via `Register-DeferredPromptHook`.

## Dependencies

See `install-deps.ps1` and `Taskfile.yaml` for required PowerShell modules and Scoop packages.

## Notes

- `.env.ps1` and `.path` are git-ignored; they contain machine-specific settings.
- `bins/` is git-ignored; place extra portable tools there.
