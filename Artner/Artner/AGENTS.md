# Artner App Sources

Generated: 2026-02-23T01:25:25Z
Branch: main
Commit: 35a05b7

## Overview

This directory is the app target source root. It contains the UIKit lifecycle entry points, the root coordinator, and the Clean Architecture layers.

## Structure

```
Artner/Artner/
|-- AppDelegate.swift
|-- SceneDelegate.swift
|-- Info.plist
|-- Cooldinator/                  # root navigation coordinator (spelling is intentional in repo)
|-- Core/                         # base protocols + constants
|-- Data/                         # implementations (Network/Storage/RepositoryImpl/UseCaseImpl)
|-- Domain/                       # pure contracts (Entity/Repository/UseCase)
|-- Features/                     # per-feature *Coordinating protocols (navigation surface)
|-- Presentation/                 # UIKit MVVM screens + shared UI
|-- Extension/                    # UIKit extensions
`-- Resources/                    # assets/fonts/colors
```

## Boot Flow (Runtime)

- `AppDelegate` initializes Kakao SDK.
- `SceneDelegate` creates the window and shows `LaunchViewController` first.
- After login, `SceneDelegate.showMainScreen()` creates `AppCoordinator(window:)` and calls `start()`.
- `AppCoordinator.start()` configures `DIContainer.shared`, builds `HomeViewController`, and installs a `UINavigationController` as the window root.

Key files:
- Entry points: `Artner/Artner/AppDelegate.swift`, `Artner/Artner/SceneDelegate.swift`
- Root navigation: `Artner/Artner/Cooldinator/AppCoordinator.swift`
- DI wiring: `Artner/Artner/Data/Network/DIContainer.swift`

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Add a new screen | `Artner/Artner/Presentation/<Feature>/` | Use ViewController + ViewModel + optional View folder |
| Add navigation to a screen | `Artner/Artner/Features/<Feature>/*Coordinating.swift`, `Artner/Artner/Cooldinator/AppCoordinator.swift` | Add protocol method, implement in AppCoordinator |
| Add API endpoint | `Artner/Artner/Data/Network/APITarget.swift` | Define Moya target + parameters/headers |
| Add a DTO | `Artner/Artner/Data/Network/DTOs/` | Prefer explicit CodingKeys for snake_case mapping |
| Add repository/usecase | `Artner/Artner/Domain/Repository/`, `Artner/Artner/Data/RepositoryImpl/`, `Artner/Artner/Domain/UseCase/`, `Artner/Artner/Data/UseCaseImpl/` | Protocol in Domain; implementation in Data |
| Token handling | `Artner/Artner/Data/Storage/` | Keychain + token manager |

## Conventions

- MVVM: ViewController binds to ViewModel (Combine) and owns the view.
- Navigation: ViewControllers should route via coordinator interfaces (see "deprecated - coordinator usage recommended" markers).
- Language: repo docs/comments are typically Korean; identifiers are English (see `CLAUDE.md`).

## Subdirectory AGENTS

- `Artner/Artner/Cooldinator/AGENTS.md`
- `Artner/Artner/Features/AGENTS.md`
- `Artner/Artner/Domain/AGENTS.md`
- `Artner/Artner/Data/AGENTS.md`
- `Artner/Artner/Presentation/AGENTS.md`
