# Presentation Layer

## Overview

UIKit UI layer, structured as MVVM per feature. Shared UI components live in `Common/`, and base classes live in `Base/`.

## Structure

```
Presentation/
|-- Base/            # BaseViewController/BaseView
|-- Common/          # ToastManager, navigation bars, shared UI
|-- Home/
|-- Entry/
|-- Player/
|-- Camera/
|-- Save/
|-- Like/
|-- Record/
|-- Underline/
`-- Launch/
```

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Base screen conventions | `Artner/Artner/Presentation/Base/BaseViewController.swift` | Enforces no Storyboards; override `setupUI/setupBinding` |
| Shared UI + toasts | `Artner/Artner/Presentation/Common/` | See `README_Toast.md` for behavior/spec |
| Save/Sidebar UI | `Artner/Artner/Presentation/Save/` | Includes sidebar implementation under `Save/Sidebar/` |
| Player UI + highlight flows | `Artner/Artner/Presentation/Player/` | PlayerViewModel is a large hotspot |
| Record input flow | `Artner/Artner/Presentation/Record/` | Has detailed `README_RecordInput.md` |

## Conventions

- Folder pattern per feature: `ViewController/`, `ViewModel/`, and optional `View/`.
- Many layouts use SnapKit (see `BaseView.swift`).

## Anti-Patterns

- Storyboards are not used: storyboard initializers crash by design.
- Screens annotated as "deprecated - coordinator usage recommended" should route through `AppCoordinator` instead of direct VC transitions.

## Subdirectory AGENTS

- `Artner/Artner/Presentation/Home/AGENTS.md`
- `Artner/Artner/Presentation/Entry/AGENTS.md`
- `Artner/Artner/Presentation/Player/AGENTS.md`
- `Artner/Artner/Presentation/Save/AGENTS.md`
- `Artner/Artner/Presentation/Record/AGENTS.md`
