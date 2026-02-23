# Presentation/Home

## Overview

Home is the main feed screen and the initial screen after `AppCoordinator.start()`.

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Home screen controller | `Artner/Artner/Presentation/Home/ViewController/HomeViewController.swift` | Installs handlers for camera + sidebar |
| Home view model | `Artner/Artner/Presentation/Home/ViewModel/HomeViewModel.swift` | Feed + likes data flow |
| Home UI views | `Artner/Artner/Presentation/Home/View/` | Table cells + banners |

## Notes

- Navigation out of Home goes through coordinator closures (`onCameraTapped`, `onShowSidebar`).
