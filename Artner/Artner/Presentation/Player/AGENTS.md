# Presentation/Player

## Overview

Audio player screen. The coordinator may stream audio on-demand before pushing Player.

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Player controller | `Artner/Artner/Presentation/Player/ViewController/PlayerViewController.swift` | Binds UI to PlayerViewModel |
| Player view model (hotspot) | `Artner/Artner/Presentation/Player/ViewModel/PlayerViewModel.swift` | Large file; key behavior and state |
| Player UI view | `Artner/Artner/Presentation/Player/View/PlayerView.swift` | UI layout + paragraph list |
| Audio streaming | `Artner/Artner/Data/Network/APIService.swift` | `streamAudio(jobId:)` |
| Navigation to Player | `Artner/Artner/Cooldinator/AppCoordinator.swift` | Streams audio if needed, then pushes Player |

## Notes

- If `Docent.audioURL` is nil but `audioJobId` exists, `AppCoordinator.showPlayer(docent:)` streams audio first.
