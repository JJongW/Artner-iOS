# Data/Storage

## Overview

Local persistence for auth tokens and runtime dummy data used by some repositories.

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Token manager | `Artner/Artner/Data/Storage/TokenManager.swift` | Token access helpers; posts logout/force-logout signals |
| Keychain implementation | `Artner/Artner/Data/Storage/KeychainTokenManager.swift` | Keychain storage for tokens |
| Dummy docent data | `Artner/Artner/Data/Storage/Dummy/` | In-app stub dataset (not XCTest mocks) |

## Notes

- Repo docs mention dev env vars for tokens; runtime auth also integrates Kakao login + Keychain.
