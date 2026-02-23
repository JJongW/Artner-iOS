# Presentation/Entry

## Overview

Entry is the docent entry point (detail + chat entry). It is pushed from Home via `AppCoordinator.showEntry(docent:)`.

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Entry controller | `Artner/Artner/Presentation/Entry/ViewController/EntryViewController.swift` | Owns EntryView + binds to ViewModel |
| Chat controller | `Artner/Artner/Presentation/Entry/ViewController/ChatViewController.swift` | Keyword-based chat flow |
| Entry view models | `Artner/Artner/Presentation/Entry/ViewModel/` | `EntryViewModel`, `ChatViewModel` |
| Entry UI views | `Artner/Artner/Presentation/Entry/View/` | Includes `EntryView.swift`, chat cells, input bar |

## Notes

- Chat navigation uses `EntryCoordinating.showChat(docent:keyword:)` implemented in `AppCoordinator`.
