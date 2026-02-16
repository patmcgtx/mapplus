import Testing
@testable import MapPlus

struct StringExtensionsTests {
    
    // MARK: - isPopulated Tests
    
    // Test data for isPopulated parameterized tests
    struct IsPopulatedTestCase {
        let input: String
        let expected: Bool
        let description: String
    }
    
    @Test("isPopulated property", arguments: [
        IsPopulatedTestCase(
            input: "",
            expected: false,
            description: "Empty string"
        ),
        IsPopulatedTestCase(
            input: " ",
            expected: false,
            description: "Single space"
        ),
        IsPopulatedTestCase(
            input: "  ",
            expected: false,
            description: "Multiple spaces"
        ),
        IsPopulatedTestCase(
            input: "\t",
            expected: false,
            description: "Tab character"
        ),
        IsPopulatedTestCase(
            input: "\n",
            expected: false,
            description: "Newline character"
        ),
        IsPopulatedTestCase(
            input: "\r\n",
            expected: false,
            description: "Carriage return and newline"
        ),
        IsPopulatedTestCase(
            input: " \t\n ",
            expected: false,
            description: "Mixed whitespace characters"
        ),
        IsPopulatedTestCase(
            input: "a",
            expected: true,
            description: "Single character"
        ),
        IsPopulatedTestCase(
            input: "Hello",
            expected: true,
            description: "Simple word"
        ),
        IsPopulatedTestCase(
            input: " Hello ",
            expected: true,
            description: "Word with leading and trailing spaces"
        ),
        IsPopulatedTestCase(
            input: "\tHello\n",
            expected: true,
            description: "Word with leading tab and trailing newline"
        ),
        IsPopulatedTestCase(
            input: "Hello World",
            expected: true,
            description: "Multiple words"
        ),
        IsPopulatedTestCase(
            input: "  Hello  World  ",
            expected: true,
            description: "Multiple words with extra spaces"
        ),
        IsPopulatedTestCase(
            input: "123",
            expected: true,
            description: "Numeric string"
        ),
        IsPopulatedTestCase(
            input: "!@#$%",
            expected: true,
            description: "Special characters"
        ),
        IsPopulatedTestCase(
            input: "🎉",
            expected: true,
            description: "Emoji"
        ),
        IsPopulatedTestCase(
            input: " 🎉 ",
            expected: true,
            description: "Emoji with whitespace"
        )
    ])
    func testIsPopulated(testCase: IsPopulatedTestCase) {
        let result = testCase.input.isPopulated
        #expect(result == testCase.expected, 
                "Expected isPopulated to be \(testCase.expected) for '\(testCase.description)' but got \(result)")
    }
    
    // MARK: - localized Tests
    
    @Test("localized property returns non-empty string")
    func testLocalizedReturnsString() {
        // Test that localized property returns a string (may be the same as input if no localization exists)
        let testString = "test-key"
        let result = testString.localized
        
        // The result should be a non-nil string
        #expect(!result.isEmpty, "localized property should return a non-empty string")
    }
    
    @Test("localized property with empty string")
    func testLocalizedWithEmptyString() {
        let emptyString = ""
        let result = emptyString.localized
        
        // Even an empty string should return something (itself)
        #expect(result == emptyString, "localized property should handle empty strings")
    }
    
    @Test("localized property preserves string when no localization exists")
    func testLocalizedPreservesStringWhenNoLocalizationExists() {
        // For a key that doesn't exist in localization, it should return the key itself
        let uniqueKey = "this-is-a-very-unique-test-key-that-definitely-does-not-exist-12345"
        let result = uniqueKey.localized
        
        // Should return the original key when no localization is found
        #expect(result == uniqueKey, "localized property should return the original key when no localization exists")
    }
}
