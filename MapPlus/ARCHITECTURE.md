# MapPlus Architecture

## Overview

MapPlus is an iOS app for saving and organizing personal points of interest on a map. It uses a pragmatic hybrid of MVVM and SwiftData reactivity, with protocol-based services for testability.

**Core frameworks:** SwiftUI, SwiftData, MapKit, CoreLocation, FoundationModels (on-device AI)

---

## Directory Structure

```
MapPlus/
├── MapPlus/                 # App source code
│   ├── MapPlusApp.swift      # Entry point
│   ├── Common/               # Shared helpers (e.g., Environment)
│   ├── Extensions/           # Swift extensions
│   ├── Persistence/          # SwiftData models + containers/stores
│   ├── Preferences/          # App settings / AppStorage keys
│   ├── Services/             # Business logic and external APIs
│   ├── Theming/              # Themes, fonts, styling
│   └── Views/                # SwiftUI views (incl. Views/View Models/)
├── MapPlusTests/             # Unit tests (Swift Testing)
└── MapPlusUITests/           # UI tests
```

---

## Layers

### 1. Persistence Layer (SwiftData Models)

Three `@Model` types form the data model:

| Model | Role |
|---|---|
| `Landmark` | Core entity — name, notes, symbol, coordinates, formatted address |
| `LandmarkCategory` | Groups landmarks; many-to-many relationship with `Landmark` |
| `SelectedCategories` | Singleton persisting active filter state (selected categories + AND/OR mode) |

`ModelContainers.swift` provides factory methods for both production and in-memory test containers.

`LandmarkStore` is a thin service over SwiftData for committing landmark changes from view models.

### 2. Service Layer

Services encapsulate external API calls and business logic behind protocols. Each service has a real MapKit/FoundationModels implementation and a mock for testing.

| Protocol | Real Implementation | Purpose |
|---|---|---|
| `LocationService` | `MapKitLocationService` | Get current user location, reverse geocoding |
| `AddressLookupService` | `MapKitAddressLookupService` | Text-based location search via `MKLocalSearch` |
| `LookAroundService` | `MapKitLookAroundService` | Fetch `MKLookAroundScene` for street-level previews |
| `MapItemSuggestionService` | `AIMapItemSuggestionService` | On-device AI for landmark name/symbol suggestions |
| `CategorySelectionService` | `DefaultCategorySelectionService` | Filter landmark list by category; persists via SwiftData |

Services are injected into views via SwiftUI `@Environment` values (defined in `Environment.swift`), allowing easy swapping of mocks in tests without constructor changes.

`MapItemsExplorer` wraps a stream of `MKMapItem` results and fetches AI suggestions for each, providing the lazy-loading sequence consumed by `LandmarkFormViewModel`.

### 3. ViewModel Layer

ViewModels use the `@Observable` macro and are bound to `@MainActor`. They orchestrate service calls, manage multi-step interaction states via enums, and expose reactive properties to views.

| ViewModel | Drives | Key Responsibility |
|---|---|---|
| `MainMapViewModel` | `MainMapView` | Map region, selected annotation, sheet visibility, location permission |
| `LandmarkFormViewModel` | `LandmarkForm` | Create/edit mode, address search lifecycle, AI suggestions, save state |
| `CategoriesEditViewModel` | Category edit UI | Category CRUD |
| `CategoriesSelectFlowViewModel` | `CategoriesSelectFlow` | Delegates filter logic to `CategorySelectionService` |

State machines are represented as enums with associated values, for example:

```swift
enum AddressSearchState {
    case searchInitial
    case searching
    case searchResolved(LocationInfo)
    case searchFailed(Error)
}
```

### 4. View Layer

Views are SwiftUI and generally own no business logic — they bind to a ViewModel or SwiftData `@Query`, and forward user actions to the ViewModel.

| View | Role |
|---|---|
| `MainMapView` | Primary map with landmark annotations, floating controls, glow animations |
| `LandmarkForm` | Create/edit landmark — address search, AI suggestions, category picker |
| `LandmarksView` | Scrollable list of all landmarks |
| `LandmarkDetailsView` | Detail sheet — info, notes, categories, LookAround preview |
| `CategoriesSelectFlow` | Category filter selector with AND/OR mode picker |

Top-level persistent state (all landmarks, filter selections) is fetched reactively with `@Query`, which auto-updates when SwiftData models change.

---

## Data Flow

### Adding a Landmark (end-to-end example)

```
User taps "+" on MainMapView
  → MainMapViewModel.isShowingAddLandmarkSheet = true
  → LandmarkForm presented (create mode)
  → User types an address
  → LandmarkFormViewModel.searchByText()
  → AddressLookupService → [MKMapItem]
  → MapItemsExplorer fetches AI suggestions per item
  → AddressSearchState becomes .searchResolved(LocationInfo)
  → User selects a result and taps Save
  → LandmarkFormViewModel.save(using: LandmarkStore)
  → LandmarkStore.commit() inserts Landmark into SwiftData
  → @Query in MainMapView auto-observes change
  → New annotation appears with glow animation
```

---

## Key Patterns

**Protocol-based services with environment injection** — every external dependency is behind a protocol, injected via `@Environment`, and mocked in tests.

**@Observable ViewModels** — uses Swift 5.9+ `@Observable` macro rather than `ObservableObject`/Combine.

**State machine enums** — multi-step flows (search, save) are modeled as enums with associated values rather than multiple boolean flags.

**SwiftData reactivity** — `@Query` replaces explicit fetch/refresh cycles; the view layer reacts automatically to model changes.

**On-device AI** — `AIMapItemSuggestionService` uses `FoundationModels.LanguageModelSession` to suggest landmark names and emoji symbols; `BasicMapItemSuggestionService` is the fallback when AI is unavailable.

---

## Testing

Tests live under `MapPlusTests/` and use the **Swift Testing** framework (`@Test` macros).

- ViewModels are tested by injecting mock services and asserting state transitions
- SwiftData operations use in-memory containers from `ModelContainers.inMemorySampleContainer()`
- Parameterized tests (`@Test(arguments:)`) cover multi-case scenarios
- Mock service implementations (`MockLocationService`, `MockAddressLookupService`, `MockLookAroundService`) mirror the protocols exactly and are used for tests and DEBUG previews.
