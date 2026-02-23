# Data/Network

## Overview

Networking is built on Moya. `APITarget` defines endpoints; `APIService` executes requests and handles refresh/retry.

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Define endpoint | `Artner/Artner/Data/Network/APITarget.swift` | TargetType: path/method/task/headers |
| Execute request (Combine) | `Artner/Artner/Data/Network/APIService.swift` | `request(target:responseType:)` + retry/refresh |
| Execute request (completion) | `Artner/Artner/Data/Network/APIService.swift` | `request(_:completion:)` for UIKit-compatible flows |
| Error taxonomy | `Artner/Artner/Data/Network/NetworkError.swift` | Central network error enum |
| DTO definitions | `Artner/Artner/Data/Network/DTOs/` | DTO -> Domain conversion where needed |
| DI wiring | `Artner/Artner/Data/Network/DIContainer.swift` | Wires APIService + repos + usecases |

## Conventions

- Auth header is added in `APITarget` (Bearer token) when available.
- Token refresh + retry logic lives in `APIService`.

## Anti-Patterns

- Avoid adding new direct `APIService.shared` usages from Presentation when there is already a UseCase/Repository flow. (Existing exceptions exist, e.g., Player audio streaming from `AppCoordinator`.)
