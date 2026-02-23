# Domain Layer

## Overview

Domain is the contract layer: Entities (models) and protocol definitions for repositories and use cases.

## Structure

```
Domain/
|-- Entity/          # domain models
|-- Repository/      # repository protocols
`-- UseCase/         # usecase protocols
```

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Domain models | `Artner/Artner/Domain/Entity/` | Codable/Decodable models used across layers |
| Data contracts | `Artner/Artner/Domain/Repository/` | Protocol seams for mocking/stubbing |
| Use case contracts | `Artner/Artner/Domain/UseCase/` | Often return Combine `AnyPublisher` |

## Conventions

- Keep Domain free of UIKit and app-specific framework dependencies.
