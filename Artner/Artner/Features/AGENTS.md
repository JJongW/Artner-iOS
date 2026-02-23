# Features (Coordinating Protocols)

## Overview

This folder contains per-feature `*Coordinating` protocols used as the navigation interface boundary. `AppCoordinator` implements these protocols.

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Add navigation surface for a feature | `Artner/Artner/Features/<Feature>/*Coordinating.swift` | Add protocol method(s) for the flow |
| Implement navigation | `Artner/Artner/Cooldinator/AppCoordinator.swift` | Conform + implement the new method(s) |
| Shared coordinator base | `Artner/Artner/Core/Base/Coordinator/Coordinator.swift` | Base `Coordinator` protocol |

## Conventions

- Protocol naming: `<Feature>Coordinating`.
- Keep these protocols UIKit-light; they define navigation intent, not view layout.
