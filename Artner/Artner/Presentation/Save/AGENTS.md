# Presentation/Save

## Overview

Save manages folders and saved docent items, plus the sidebar menu UI under `Save/Sidebar/`.

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Save controller(s) | `Artner/Artner/Presentation/Save/ViewController/` | Folder list + folder detail |
| Save view model | `Artner/Artner/Presentation/Save/ViewModel/SaveViewModel.swift` | Uses folder use cases from DIContainer |
| Sidebar container | `Artner/Artner/Presentation/Save/Sidebar/View/SideMenuContainerView.swift` | Sidebar presentation/dismiss animation |
| Sidebar controller | `Artner/Artner/Presentation/Save/Sidebar/ViewController/SidebarViewController.swift` | Calls coordinator delegate for menu actions |

## Anti-Patterns

- Sidebar VC has TODO markers (e.g., account deletion) that are not implemented.
