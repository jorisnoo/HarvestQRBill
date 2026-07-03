//
//  TemplateEngineTests.swift
//  HarvieTests
//

import Foundation
import Testing
@testable import Harvie

struct TemplateEngineTests {

    // MARK: - Variable Interpolation

    @Test func simpleVariable() {
        let result = TemplateEngine.render("Hello {{name}}", with: ["name": "World"])
        #expect(result == "Hello World")
    }

    @Test func dotNotationVariable() {
        let context: [String: Any] = [
            "invoice": ["number": "2024-001"]
        ]
        let result = TemplateEngine.render("Invoice {{invoice.number}}", with: context)
        #expect(result == "Invoice 2024-001")
    }

    @Test func missingVariableRendersEmpty() {
        let result = TemplateEngine.render("Hello {{missing}}", with: [:])
        #expect(result == "Hello ")
    }

    @Test func multipleVariables() {
        let context: [String: Any] = ["first": "John", "last": "Doe"]
        let result = TemplateEngine.render("{{first}} {{last}}", with: context)
        #expect(result == "John Doe")
    }

    @Test func decimalVariable() {
        let context: [String: Any] = ["amount": Decimal(1500.50)]
        let result = TemplateEngine.render("Total: {{amount}}", with: context)
        #expect(result == "Total: 1500.5")
    }

    // MARK: - Sections (Iteration)

    @Test func sectionIteration() {
        let context: [String: Any] = [
            "items": [
                ["name": "Apple"],
                ["name": "Banana"]
            ]
        ]
        let result = TemplateEngine.render("{{#items}}{{name}} {{/items}}", with: context)
        #expect(result == "Apple Banana ")
    }

    @Test func emptySectionRendersNothing() {
        let context: [String: Any] = [
            "items": [[String: Any]]()
        ]
        let result = TemplateEngine.render("before{{#items}}item{{/items}}after", with: context)
        #expect(result == "beforeafter")
    }

    @Test func sectionWithParentContext() {
        let context: [String: Any] = [
            "currency": "CHF",
            "items": [
                ["amount": "100"]
            ]
        ]
        let result = TemplateEngine.render("{{#items}}{{amount}} {{currency}}{{/items}}", with: context)
        #expect(result == "100 CHF")
    }

    // MARK: - Conditionals

    @Test func conditionalTrue() {
        let context: [String: Any] = ["show": true]
        let result = TemplateEngine.render("{{#if show}}visible{{/if}}", with: context)
        #expect(result == "visible")
    }

    @Test func conditionalFalse() {
        let context: [String: Any] = ["show": false]
        let result = TemplateEngine.render("{{#if show}}visible{{/if}}", with: context)
        #expect(result == "")
    }

    @Test func conditionalNonEmptyString() {
        let context: [String: Any] = ["notes": "Hello"]
        let result = TemplateEngine.render("{{#if notes}}has notes{{/if}}", with: context)
        #expect(result == "has notes")
    }

    @Test func conditionalEmptyString() {
        let context: [String: Any] = ["notes": ""]
        let result = TemplateEngine.render("{{#if notes}}has notes{{/if}}", with: context)
        #expect(result == "")
    }

    @Test func conditionalMissing() {
        let result = TemplateEngine.render("{{#if missing}}visible{{/if}}", with: [:])
        #expect(result == "")
    }

    @Test func conditionalDotNotation() {
        let context: [String: Any] = [
            "invoice": ["hasNotes": true]
        ]
        let result = TemplateEngine.render("{{#if invoice.hasNotes}}notes{{/if}}", with: context)
        #expect(result == "notes")
    }

    // MARK: - Filters

    @Test func currencyFilter() {
        let context: [String: Any] = ["amount": Decimal(1500.50)]
        let result = TemplateEngine.render("{{amount | currency}}", with: context)
        #expect(result.contains("1") && result.contains("500"))
    }

    @Test func dateFilter() {
        let calendar = Calendar.current
        let components = DateComponents(year: 2024, month: 3, day: 15)
        let date = calendar.date(from: components)!
        let context: [String: Any] = ["date": date]
        let result = TemplateEngine.render("{{date | date:\"dd.MM.yyyy\"}}", with: context)
        #expect(result == "15.03.2024")
    }

    @Test func numberFilter() {
        let context: [String: Any] = ["qty": Decimal(42)]
        let result = TemplateEngine.render("{{qty | number:1}}", with: context)
        #expect(result == "42.0")
    }

    @Test func trimmedNumberFilterHidesTrailingZeros() {
        let whole = TemplateEngine.render("{{qty | numberTrimmed:1}}", with: ["qty": Decimal(42)])
        let fractional = TemplateEngine.render("{{qty | numberTrimmed:1}}", with: ["qty": Decimal(string: "4.5")!])
        #expect(whole == "42")
        #expect(fractional == "4.5")
    }

    @Test func filterOnMissingValue() {
        let result = TemplateEngine.render("{{missing | currency}}", with: [:])
        #expect(result == "")
    }

    // MARK: - Markdown Filter

    @Test func markdownLineBreaks() {
        let context: [String: Any] = ["text": "Line one\nLine two"]
        let result = TemplateEngine.render("{{text | markdown}}", with: context)
        #expect(result == "Line one<br>Line two")
    }

    @Test func markdownBold() {
        let context: [String: Any] = ["text": "This is **bold** text"]
        let result = TemplateEngine.render("{{text | markdown}}", with: context)
        #expect(result == "This is <strong>bold</strong> text")
    }

    @Test func markdownSingleAsteriskBold() {
        let context: [String: Any] = ["text": "This is *bold* text"]
        let result = TemplateEngine.render("{{text | markdown}}", with: context)
        #expect(result == "This is <strong>bold</strong> text")
    }

    @Test func markdownHTMLEscaping() {
        let context: [String: Any] = ["text": "<script>alert('xss')</script>"]
        let result = TemplateEngine.render("{{text | markdown}}", with: context)
        #expect(result == "&lt;script&gt;alert('xss')&lt;/script&gt;")
    }

    @Test func markdownCombined() {
        let context: [String: Any] = ["text": "**Bold** and *also bold*\nNew line"]
        let result = TemplateEngine.render("{{text | markdown}}", with: context)
        #expect(result == "<strong>Bold</strong> and <strong>also bold</strong><br>New line")
    }

    // MARK: - Edge Cases

    @Test func malformedTag() {
        let result = TemplateEngine.render("Hello {{name", with: ["name": "World"])
        #expect(result == "Hello {{name")
    }

    @Test func emptyTemplate() {
        let result = TemplateEngine.render("", with: [:])
        #expect(result == "")
    }

    @Test func noTags() {
        let result = TemplateEngine.render("Just plain text", with: [:])
        #expect(result == "Just plain text")
    }

    @Test func nestedDotPath() {
        let context: [String: Any] = [
            "a": ["b": ["c": "deep"]]
        ]
        let result = TemplateEngine.render("{{a.b.c}}", with: context)
        #expect(result == "deep")
    }

    @Test func htmlContent() {
        let context: [String: Any] = ["name": "World"]
        let result = TemplateEngine.render("<h1>{{name}}</h1>", with: context)
        #expect(result == "<h1>World</h1>")
    }
}
