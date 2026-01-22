# Artner-iOS

iOS app for art docent (도슨트) experience - provides AI-powered audio guides for artwork.

## Project Structure

```
Artner/Artner/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Cooldinator/          # Coordinator pattern for navigation
│   └── AppCoordinator.swift
├── Domain/               # Business logic layer (Clean Architecture)
│   ├── Entity/           # Domain models
│   ├── Repository/       # Repository protocols
│   └── UseCase/          # UseCase protocols
├── Data/                 # Data layer implementation
│   ├── Network/          # API service, DTOs, DIContainer
│   ├── RepositoryImpl/   # Repository implementations
│   ├── UseCaseImpl/      # UseCase implementations
│   └── Storage/          # Keychain, TokenManager
├── Presentation/         # UI layer
│   ├── Base/             # BaseViewController
│   ├── Common/           # Shared UI components (ToastManager, NavigationBar, etc.)
│   ├── Home/             # Main feed screen
│   ├── Entry/            # Docent entry point
│   ├── Player/           # Audio player screen
│   ├── Camera/           # Camera for artwork scanning
│   ├── Save/             # Saved folders
│   ├── Like/             # Liked items
│   ├── Record/           # Exhibition records
│   ├── Underline/        # Highlighted items
│   └── Launch/           # Login screen
├── Extension/            # UIKit extensions
└── Resources/            # Assets, colors, fonts
```

## Architecture

- **Clean Architecture** with Domain, Data, Presentation layers
- **Coordinator Pattern** for navigation (`AppCoordinator`)
- **MVVM** in Presentation layer
- **Dependency Injection** via `DIContainer` singleton
- **Combine** for reactive programming

## Key Components

### DIContainer (`Data/Network/DIContainer.swift`)
Singleton container for dependency injection. Use factory methods like:
- `makeHomeViewModel()`
- `makePlayerViewModel(docent:)`
- `makeSaveViewModel()`

### AppCoordinator (`Cooldinator/AppCoordinator.swift`)
Handles all navigation:
- `showEntry(docent:)` - Docent detail
- `showPlayer(docent:)` - Audio player
- `showCamera()` - Camera screen
- `showSidebar(from:)` - Side menu

### ToastManager (`Presentation/Common/ToastManager.swift`)
Singleton for toast notifications:
- `showSuccess(_:)`, `showError(_:)`, `showLoading(_:)`

## Build & Run

Open `Artner/Artner.xcodeproj` in Xcode.

### Environment Variables (Required for Development)
Set in Xcode: Product → Scheme → Edit Scheme → Run → Environment Variables:
- `DEV_ACCESS_TOKEN`
- `DEV_REFRESH_TOKEN`

## Common Patterns

### Creating a new screen
1. Create ViewModel in `Presentation/{Feature}/ViewModel/`
2. Create ViewController in `Presentation/{Feature}/ViewController/`
3. Create View in `Presentation/{Feature}/View/` (if needed)
4. Add factory method to `DIContainer`
5. Add navigation method to `AppCoordinator`

### API Calls
1. Define endpoint in `Data/Network/APITarget.swift`
2. Create DTO in `Data/Network/DTOs/`
3. Create/update Repository protocol in `Domain/Repository/`
4. Implement in `Data/RepositoryImpl/`
5. Create UseCase if needed

## Language

- Code comments and documentation: Korean (한국어)
- Variable/function names: English
