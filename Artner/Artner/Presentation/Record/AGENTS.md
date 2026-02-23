# Presentation/Record

## Overview

Record feature handles exhibition records. The RecordInput flow is documented in detail.

## Where To Look

| Task | Location | Notes |
|------|----------|-------|
| Record list controller | `Artner/Artner/Presentation/Record/ViewController/RecordViewController.swift` | List + navigation to input |
| Record input controller | `Artner/Artner/Presentation/Record/ViewController/RecordInputViewController.swift` | Date picker + form submission |
| Record view models | `Artner/Artner/Presentation/Record/ViewModel/` | `RecordViewModel`, `RecordInputViewModel` |
| Feature-specific doc | `Artner/Artner/Presentation/Record/README_RecordInput.md` | API body rules + UX spec |

## Notes

- Record creation broadcasts `recordDidCreate` via NotificationCenter (see README_RecordInput.md).
