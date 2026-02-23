# PROJECT KNOWLEDGE BASE

Generated: 2026-02-23T01:25:25Z
Branch: main
Commit: 35a05b7

## Overview

Artner-iOS is a UIKit iOS app (Swift) for an AI-powered art docent experience. Architecture is Clean Architecture (Domain/Data/Presentation) + MVVM + Coordinator, with Combine for async flows.

Primary source root: `Artner/Artner/` (this repo is nested: `Artner/Artner`).

## Structure

```
./
|-- Artner/
|   |-- Artner/                  # app target sources (SEE: Artner/Artner/AGENTS.md)
|   `-- Artner.xcodeproj/         # Xcode project (scheme: Artner)
|-- README.md                     # dev env vars + security rules
|-- CLAUDE.md                     # architecture + project conventions
`-- UNUSED_CODE_REPORT.md         # historical cleanup notes
```

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| App entry + boot flow | `Artner/Artner/AppDelegate.swift`, `Artner/Artner/SceneDelegate.swift` | SceneDelegate starts on Launch, then hands off to AppCoordinator |
| Navigation (Coordinator) | `Artner/Artner/Cooldinator/AppCoordinator.swift` | Root coordinator implements per-feature `*Coordinating` protocols |
| Dependency Injection (DI) | `Artner/Artner/Data/Network/DIContainer.swift` | Singleton container + ViewModel factory methods |
| Networking (Moya) | `Artner/Artner/Data/Network/APITarget.swift`, `Artner/Artner/Data/Network/APIService.swift` | TargetType + APIService with retry/refresh logic |
| UI layer | `Artner/Artner/Presentation/` | UIKit MVVM; no Storyboards |
| Domain contracts | `Artner/Artner/Domain/` | Entities + repository/usecase protocols |

## Local Commands

Open in Xcode:

```bash
open Artner/Artner.xcodeproj
```

Resolve SPM + build for simulator (no signing):

```bash
xcodebuild -resolvePackageDependencies -project Artner/Artner.xcodeproj -scheme Artner
xcodebuild -project Artner/Artner.xcodeproj -scheme Artner -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Notes:
- No in-repo CI config: `.github/workflows` is absent.
- No test targets currently; `xcodebuild test` is effectively a smoke build.

## Conventions (Repo-Specific)

- Architecture boundaries: Domain is protocol/model-only; Data implements repositories/usecases; Presentation is UIKit MVVM.
- Feature navigation surface lives in `Artner/Artner/Features/<Feature>/*Coordinating.swift` and is implemented by `AppCoordinator`.
- Security: dev tokens are configured via Xcode scheme env vars; do not hardcode tokens.

## Anti-Patterns (This Repo)

- Do not commit secrets: `.env*`, `config.plist`, `secrets.plist` (see `.gitignore` and `README.md`).
- No Storyboards: base controllers crash on storyboard init (see `Artner/Artner/Presentation/Base/BaseViewController.swift`).
- Prefer coordinator-driven navigation: multiple screens are annotated as "deprecated - coordinator usage recommended".
- Auth note: Launch flow contains warnings about missing token validity verification (see `Artner/Artner/Presentation/Launch/ViewModel/LaunchViewModel.swift`).

## AGENTS Hierarchy

- `Artner/Artner/AGENTS.md` (app source root)
