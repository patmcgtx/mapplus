# Localization

This app supports multiple languages through Apple's String Catalog localization system.

## Supported Languages

- English (en) - Source language
- Spanish (es)

## How It Works

All user-facing strings are localized using the `Localizable.xcstrings` file, which is Apple's modern approach to localization (introduced in Xcode 15). This file contains all translations in a single JSON-based catalog.

### Using Localized Strings in Code

In SwiftUI views, use the `String(localized:)` initializer:

```swift
// For Text views
Text(String(localized: "My Places"))

// For Button labels
Button(String(localized: "Save")) {
    // action
}

// For navigation titles
.navigationTitle(String(localized: "Details"))

// For TextField placeholders
TextField(String(localized: "Name"), text: $name)
```

### Adding New Strings

1. Add the string to your code using `String(localized: "Your String")`
2. Build the app in Xcode - it will automatically detect the new string
3. Add translations in the `Localizable.xcstrings` file

### Adding a New Language

1. In Xcode, select the `Localizable.xcstrings` file
2. Click the "+" button in the localizations section
3. Select the new language
4. Provide translations for all strings

## String Catalog Structure

The `Localizable.xcstrings` file contains:
- Source language (English)
- All localizable strings as keys
- Translations for each supported language
- State information (translated, needs review, etc.)

## Info.plist Localization

System strings like permission descriptions are localized using `InfoPlist.strings` files in language-specific `.lproj` directories:
- `en.lproj/InfoPlist.strings` - English system strings
- `es.lproj/InfoPlist.strings` - Spanish system strings

Currently localized system strings:
- `NSLocationWhenInUseUsageDescription` - Location permission message

## Testing

To test localization:
1. In Xcode, select a scheme
2. Edit the scheme and change the App Language under the Run > Options tab
3. Run the app to see the selected language

Alternatively, change your device/simulator language in Settings > General > Language & Region.
