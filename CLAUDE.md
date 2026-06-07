# Claude Instructions for MapPlus Project

## Project Structure

### Test Files
All test files belong under `MapPlus/MapPlusTests` directory.

- Use Swift Testing framework (with `@Test` macros)
- Test files should use the `@testable import MapPlus` directive
- Follow naming convention: `[FeatureName]Tests.swift`
- Use parameterized tests with `arguments:` whenever applicable to test multiple cases
- Define test case structs to organize test data for parameterized tests

## Code Conventions

- Use Swift Concurrency (async/await) where appropriate
- Prefer Swift over other languages for new code
- Use Apple frameworks and APIs (MapKit, Foundation, etc.)

