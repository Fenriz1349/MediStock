# MediStock 💊

![Swift](https://img.shields.io/badge/Swift-5.0-F05138?logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-17.5%2B-000000?logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue?logo=swift&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-MVVM%20%2B%20Clean-orange)
![CI](https://github.com/Fenriz1349/MediStock/actions/workflows/ci.yml/badge.svg)

Fork of an OpenClassrooms iOS project (P16). The original codebase was functional
but presented significant architectural, quality and reliability issues flagged by an
external audit and internal stakeholders. This fork addresses all of them.

---

## 🔧 What was done

### Architecture — MVVM + Clean Architecture

The original code called Firestore directly from views with no separation of concerns.

- Domain models made independent from Firebase
- Data access contracts (medicines, history, auth) defined as protocols
- Firebase implementations isolated in a dedicated layer
- One ViewModel per screen, no direct backend access from views
- Centralized dependency injection (composition root pattern)

### Firebase — Auth + Firestore

The fork did not compile: no Firebase project was configured.

- Firebase project created from scratch (Authentication + Firestore)
- Real-time listeners with automatic cleanup to prevent memory leaks
- Firestore database properly activated in production mode with security rules
- Server-side sorting, filtering and search (previously done in-memory)
- Lazy loading with automatic pagination for medicine lists
- Aisles stored as a proper data entity, synchronized on every add/delete

### Features & Bug Fixes

Responding to Product Owner requests and internal notes:

- Medicine add form (the "+" button was creating a random medicine)
- Medicine deletion with confirmation dialog, traced in history
- User account tab: logout, account deletion (required for App Store submission)
- Auth error feedback: clear messages, real-time password strength validation
- Stock buttons no longer dismiss the detail screen
- Input validation: name, aisle, stock, email, password
- History reliability: missing entries fixed, enriched with user/before/after details
- Network handling: loading indicators, offline detection before writes
- Password reset by email

### UI & Accessibility

- App icon, accent color, launch screen
- Dark mode verified across all screens, contrast compliant
- Dynamic Type support on all text elements
- Reduced motion support
- VoiceOver: semantic labels, logical grouping, auto-focus on form open

### Testing

- Unit tests: ViewModels, Domain, Data, Network, Utils
- Integration tests: multi-step scenarios (create → edit, stock changes, auth flow)
- UI test: full end-to-end user journey against a dedicated local environment
  (account creation → add medicine → stock update → delete → account deletion)

### CI/CD & Versioning

- GitHub Actions pipeline: build, tests, artifact upload, run summary report
- Branch protection: merges blocked on CI failure
- release-please: automated semantic versioning from Conventional Commits
- CI skip on release-please branches to avoid unnecessary full runs
- SPM dependency caching, unused Firebase dependencies removed

---

## 🛠️ Tech stack

- Swift / SwiftUI
- Firebase (Authentication, Firestore)
- XCTest (unit, integration, UI)
- GitHub Actions / release-please
- Conventional Commits

---

## 📁 Structure

```
MediStock/
├── Core/           # DI container, app lifecycle
├── Domain/         # Models, protocols, UseCases
├── Data/           # Firebase implementations
└── Presentation/   # Views + ViewModels (one per feature)
```
