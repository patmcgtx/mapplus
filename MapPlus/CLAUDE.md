# Claude AI Assistant Instructions

**Read ARCHITECTURE.md first** — This file provides context for AI assistants working on the MapPlus codebase. Always read `ARCHITECTURE.md` for the full technical details before making architectural decisions.

---

## Project Context

MapPlus is an iOS app for saving and organizing personal points of interest. It uses SwiftUI, SwiftData, MapKit, and on-device AI (FoundationModels).

---

## Coding Standards

### General Principles

- **Swift-first**: Use modern Swift features (async/await, `@Observable`, pattern matching, etc.)
- **Protocol-oriented**: All external dependencies (services) are protocol-based
- **Testability**: Every service has a mock implementation for testing
- **SwiftUI best practices**: Prefer `@Observable` over `ObservableObject`, declarative bindings over imperative code
- **Type safety**: Use enums with associated values for state machines, not booleans

### Specific Rules

1. **Mock services belong in `MapPlus/Services/Mock services/`**
   - All mock implementations must be wrapped in `#if DEBUG` / `#endif // DEBUG`
   - Mock services should mirror their protocol exactly
   - Mock services should be configurable (delays, return values, error states)

2. **Service injection via @Environment**
   - Services are injected through SwiftUI environment values (see `Environment.swift`)
   - Never hardcode service instantiation in views or view models
   - Tests inject mocks via environment or direct parameters

3. **ViewModels are @Observable and @MainActor**
   - Use `@Observable` macro (Swift 5.9+), not `ObservableObject`
   - All ViewModels bound to `@MainActor`
   - State machines use enums (e.g., `AddressSearchState`, `SaveState`)

4. **Testing with Swift Testing framework**
   - Use `@Test` macros, not XCTest
   - Use `#expect()` for assertions
   - Use `try #require()` for unwrapping optionals
   - Use `@Test(arguments:)` for parameterized tests
   - Use in-memory SwiftData containers from `ModelContainers`
   - Test ViewModels by injecting mock services and asserting state transitions

5. **SwiftData patterns**
   - Models use `@Model` macro
   - Persistence is handled through SwiftData's `ModelContext`
   - Views use `@Query` for reactive fetching
   - `LandmarkStore` is a thin wrapper for commits/deletes

6. **Concurrency**
   - Use Swift Concurrency (async/await, actors) exclusively
   - No Dispatch, no Combine (except where required by frameworks)
   - Avoid `Task.detached` — prefer structured concurrency

7. **Error handling**
   - Custom errors conform to `Error` protocol
   - State machines represent error states explicitly (e.g., `.searchFailed(Error)`)
   - Services throw errors; ViewModels catch and update state

---

## When Making Changes

### Before writing code:

1. **Search for related files** using `query_search` to understand existing patterns
2. **Read ARCHITECTURE.md** to understand the layer you're working in
3. **Check for existing mocks** — don't duplicate mock services
4. **Look for similar ViewModels or Views** to follow established patterns

### When creating new services:

1. Define a protocol first
2. Create the real implementation
3. Create a mock implementation in `MapPlus/Services/Mock services/`
4. Wrap the mock in `#if DEBUG` / `#endif // DEBUG`
5. Add environment injection in `Environment.swift`
6. Write tests using the mock

### When creating new ViewModels:

1. Use `@Observable` and `@MainActor`
2. Model multi-step flows as state machine enums
3. Inject services via `@Environment` or initializer parameters
4. Write comprehensive tests covering all state transitions
5. Keep business logic in ViewModels, not Views

### When writing tests:

1. Use Swift Testing (`@Test`, `#expect()`)
2. Use in-memory SwiftData containers for persistence tests
3. Inject mock services to control behavior
4. Test all state transitions in state machine enums
5. Use descriptive test names that explain what's being tested
6. Group related tests with `// MARK: - Section Name`

---

## Common Pitfalls to Avoid

- ❌ Don't use `ObservableObject` — use `@Observable`
- ❌ Don't use Combine — use async/await
- ❌ Don't put business logic in Views — use ViewModels
- ❌ Don't hardcode service instantiation — use protocols and injection
- ❌ Don't use multiple booleans for state — use state machine enums
- ❌ Don't forget to wrap mocks in `#if DEBUG`
- ❌ Don't duplicate mock services — check if one exists first
- ❌ Don't use XCTest assertions — use Swift Testing (`#expect`, `#require`)

---

## File Organization

Follow the structure in ARCHITECTURE.md:

```
MapPlus/
├── Services/
│   ├── Mock services/        # ← All mocks go here, wrapped in #if DEBUG
│   └── [Protocol files]
├── Views/
│   └── View Models/          # ← ViewModels live here
├── Persistence/              # ← SwiftData models, stores, containers
└── [Other directories]
```

---

## Current Test Failures (as of 2026-06-14)

The following tests are failing due to mock service configuration issues:

- `testDifferentCoordinates()` — Mock returning "Coffee Shop" instead of parameterized names
- `testInitializeLocationWithMultipleNearbyLocations()` — Mock not applying suggestions
- `testIteratorState()` — Mock not returning configured location names
- `testSingleMapItem()` — Mock returning "Coffee Shop" instead of "Golden Gate Bridge"

**Root cause**: The mock services (likely `MockLocationService` or `MockPointOfInterestService`) are not respecting their configuration properties and are returning hardcoded default data.

**Fix approach**: Update the mock to use configured `locationsToReturn` or similar property instead of hardcoded values.

---

## Questions to Ask

When working on this codebase, if you're unsure:

- **"Does a mock already exist for this service?"** → Search for "Mock" + service name
- **"How do other ViewModels handle this pattern?"** → Search for similar ViewModels
- **"What's the right way to inject this service?"** → Check `Environment.swift`
- **"How should I test this?"** → Look at existing tests in `MapPlusTests/`
- **"Where does this file belong?"** → Reference the directory structure in ARCHITECTURE.md

---

## Summary

**Always read ARCHITECTURE.md first.** Follow the established patterns. Use protocols and mocks. Write comprehensive tests with Swift Testing. Keep the codebase clean, testable, and consistent.
