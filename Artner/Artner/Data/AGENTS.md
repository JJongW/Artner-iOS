# Data Layer

## Overview

Data implements the Domain contracts: API/DTOs, repository implementations, use case implementations, and token/storage.

## Structure

```
Data/
|-- Network/          # APIService, APITarget, DTOs, DIContainer
|-- RepositoryImpl/   # concrete repository implementations
|-- UseCaseImpl/      # concrete use case implementations
`-- Storage/          # token/keychain + runtime dummy data
```

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Add/modify an endpoint | `Artner/Artner/Data/Network/APITarget.swift` | Moya TargetType; request building |
| Add a network call | `Artner/Artner/Data/Network/APIService.swift` | Combine-first; also has completion-handler API |
| Add/modify DTOs | `Artner/Artner/Data/Network/DTOs/` | Use CodingKeys for snake_case mapping |
| Wire dependencies | `Artner/Artner/Data/Network/DIContainer.swift` | Singleton DI + ViewModel factories |
| Token persistence | `Artner/Artner/Data/Storage/` | Keychain-backed token manager |

## Subdirectory AGENTS

- `Artner/Artner/Data/Network/AGENTS.md`
- `Artner/Artner/Data/Storage/AGENTS.md`
