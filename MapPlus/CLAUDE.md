# Claude Instructions for MapPlus Project

## Project Structure

## Architecture

Please reference ARCHITECTURE.md for architectural patterns in this project.

## Code Conventions

- Use Swift Concurrency (async/await) where appropriate
- Prefer Swift over other languages for new code
- Use Apple frameworks and APIs (MapKit, Foundation, etc.)

## Localization

Reference LOCALIZATION.md for localization rules.

### Test Files

All test files belong under the `MapPlus/MapPlusTests` directory.

- Use Swift Testing framework (with `@Test` macros)
- Use parameterized tests with `arguments:` whenever applicable to test multiple cases
- Define test case structs to organize test data for parameterized tests
- Test files should use the `@testable import MapPlus` directive
- Follow naming convention: `[FeatureName]Tests.swift`
