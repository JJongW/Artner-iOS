# Cooldinator

## Overview

Root navigation lives here. `AppCoordinator` composes feature-level `*Coordinating` protocols and owns the app's `UINavigationController`.

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Root start + window root | `Artner/Artner/Cooldinator/AppCoordinator.swift` | Calls `DIContainer.shared.configureForDevelopment()` and installs Home |
| Feature navigation methods | `Artner/Artner/Cooldinator/AppCoordinator.swift` | `showEntry`, `showPlayer`, `showCamera`, sidebar flows |
| Force logout handling | `Artner/Artner/Cooldinator/AppCoordinator.swift` | Subscribes to `.forceLogout` notification |
| Audio streaming on-demand | `Artner/Artner/Cooldinator/AppCoordinator.swift` | Calls `APIService.shared.streamAudio(jobId:)` before pushing Player |

## Conventions

- Prefer coordinator-driven transitions; several ViewControllers are marked as deprecated for direct navigation.
- `AppCoordinator` is the composition root for feature screens and ViewModels (via `DIContainer`).

## Anti-Patterns

- Avoid adding new direct `present`/`push` calls inside ViewControllers when the flow already exists as a coordinator method.
