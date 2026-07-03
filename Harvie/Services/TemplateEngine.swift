//
//  TemplateEngine.swift
//  Harvie
//

import Foundation

struct TemplateEngine {

    // MARK: - Cached Formatters & Regex

    private static let dateFormatters = NSCache<NSString, DateFormatter>()
    private static let numberFormatters = NSCache<NSString, NumberFormatter>()

    private static let mediumDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    private static let boldRegex = /\*\*(.+?)\*\*/
    private static let italicRegex = /\*(.+?)\*/

    private static func cachedDateFormatter(format: String) -> DateFormatter {
        let key = format as NSString
        if let cached = dateFormatters.object(forKey: key) {
            return cached
        }
        let formatter = DateFormatter()
        formatter.dateFormat = format
        dateFormatters.setObject(formatter, forKey: key)
        return formatter
    }

    private static func cachedNumberFormatter(digits: Int) -> NumberFormatter {
        let key = "\(digits)" as NSString
        if let cached = numberFormatters.object(forKey: key) {
            return cached
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = "'"
        numberFormatters.setObject(formatter, forKey: key)
        return formatter
    }

    private static func cachedTrimmedNumberFormatter(digits: Int) -> NumberFormatter {
        let key = "trimmed-\(digits)" as NSString
        if let cached = numberFormatters.object(forKey: key) {
            return cached
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = digits
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = "'"
        numberFormatters.setObject(formatter, forKey: key)
        return formatter
    }

    enum Token {
        case text(String)
        case variable(String, filter: Filter?)
        case sectionOpen(String)
        case sectionClose(String)
        case conditionalOpen(String)
        case conditionalClose(String)
    }

    enum Filter {
        case date(String)
        case currency
        case number(Int)
        case numberTrimmed(Int)
        case markdown
    }

    // MARK: - Public

    static func render(_ template: String, with context: [String: Any]) -> String {
        let tokens = tokenize(template)
        let nodes = parse(tokens)
        return evaluate(nodes, context: context)
    }

    // MARK: - Tokenizer

    static func tokenize(_ template: String) -> [Token] {
        var tokens: [Token] = []
        var remaining = template[...]

        while let openRange = remaining.range(of: "{{") {
            // Text before the tag
            let textBefore = remaining[remaining.startIndex..<openRange.lowerBound]
            if !textBefore.isEmpty {
                tokens.append(.text(String(textBefore)))
            }

            remaining = remaining[openRange.upperBound...]

            guard let closeRange = remaining.range(of: "}}") else {
                // Malformed tag - treat rest as text
                tokens.append(.text("{{\(remaining)"))
                remaining = remaining[remaining.endIndex...]
                break
            }

            let tagContent = remaining[remaining.startIndex..<closeRange.lowerBound]
                .trimmingCharacters(in: .whitespaces)

            remaining = remaining[closeRange.upperBound...]

            if tagContent.hasPrefix("#if ") {
                let key = String(tagContent.dropFirst(4)).trimmingCharacters(in: .whitespaces)
                tokens.append(.conditionalOpen(key))
            } else if tagContent.hasPrefix("/if") {
                let key = String(tagContent.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                tokens.append(.conditionalClose(key))
            } else if tagContent.hasPrefix("#") {
                let key = String(tagContent.dropFirst(1)).trimmingCharacters(in: .whitespaces)
                tokens.append(.sectionOpen(key))
            } else if tagContent.hasPrefix("/") {
                let key = String(tagContent.dropFirst(1)).trimmingCharacters(in: .whitespaces)
                tokens.append(.sectionClose(key))
            } else {
                let (variableName, filter) = parseVariableAndFilter(tagContent)
                tokens.append(.variable(variableName, filter: filter))
            }
        }

        // Remaining text
        if !remaining.isEmpty {
            tokens.append(.text(String(remaining)))
        }

        return tokens
    }

    private static func parseVariableAndFilter(_ content: String) -> (String, Filter?) {
        let parts = content.components(separatedBy: "|")

        guard parts.count >= 2 else {
            return (content.trimmingCharacters(in: .whitespaces), nil)
        }

        let variableName = parts[0].trimmingCharacters(in: .whitespaces)
        let filterString = parts[1].trimmingCharacters(in: .whitespaces)

        let filter = parseFilter(filterString)
        return (variableName, filter)
    }

    private static func parseFilter(_ string: String) -> Filter? {
        if string.hasPrefix("date:") {
            let format = string.dropFirst(5)
                .trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
            return .date(format)
        }

        if string == "currency" {
            return .currency
        }

        if string.hasPrefix("number:") {
            let digits = string.dropFirst(7).trimmingCharacters(in: .whitespaces)
            if let n = Int(digits) {
                return .number(n)
            }
        }

        if string.hasPrefix("numberTrimmed:") {
            let digits = string.dropFirst(14).trimmingCharacters(in: .whitespaces)
            if let n = Int(digits) {
                return .numberTrimmed(n)
            }
        }

        if string == "markdown" {
            return .markdown
        }

        return nil
    }

    // MARK: - Parser

    enum Node {
        case text(String)
        case variable(String, filter: Filter?)
        case section(String, children: [Node])
        case conditional(String, children: [Node])
    }

    static func parse(_ tokens: [Token]) -> [Node] {
        var index = 0
        return parseNodes(tokens, &index)
    }

    private static func parseNodes(_ tokens: [Token], _ index: inout Int) -> [Node] {
        var nodes: [Node] = []

        while index < tokens.count {
            switch tokens[index] {
            case .text(let string):
                nodes.append(.text(string))
                index += 1

            case .variable(let name, let filter):
                nodes.append(.variable(name, filter: filter))
                index += 1

            case .sectionOpen(let key):
                index += 1
                let children = parseNodes(tokens, &index)
                nodes.append(.section(key, children: children))

            case .sectionClose:
                index += 1
                return nodes

            case .conditionalOpen(let key):
                index += 1
                let children = parseNodes(tokens, &index)
                nodes.append(.conditional(key, children: children))

            case .conditionalClose:
                index += 1
                return nodes
            }
        }

        return nodes
    }

    // MARK: - Evaluator

    static func evaluate(_ nodes: [Node], context: [String: Any]) -> String {
        var output = ""

        for node in nodes {
            switch node {
            case .text(let string):
                output += string

            case .variable(let name, let filter):
                let value = resolve(name, in: context)
                output += applyFilter(filter, to: value)

            case .section(let key, let children):
                if let items = resolve(key, in: context) as? [[String: Any]] {
                    for item in items {
                        // Merge item into context so both item fields and parent context are accessible
                        var mergedContext = context
                        for (k, v) in item {
                            mergedContext[k] = v
                        }
                        output += evaluate(children, context: mergedContext)
                    }
                }

            case .conditional(let key, let children):
                if isTruthy(resolve(key, in: context)) {
                    output += evaluate(children, context: context)
                }
            }
        }

        return output
    }

    // MARK: - Resolution

    static func resolve(_ keyPath: String, in context: [String: Any]) -> Any? {
        let parts = keyPath.components(separatedBy: ".")

        var current: Any? = context

        for part in parts {
            guard let dict = current as? [String: Any] else {
                return nil
            }
            current = dict[part]
        }

        return current
    }

    private static func isTruthy(_ value: Any?) -> Bool {
        guard let value else { return false }

        switch value {
        case let bool as Bool:
            return bool
        case let string as String:
            return !string.isEmpty
        case let number as NSNumber:
            return number.doubleValue != 0
        case let decimal as Decimal:
            return decimal != 0
        case let array as [Any]:
            return !array.isEmpty
        case is NSNull:
            return false
        default:
            return true
        }
    }

    // MARK: - Filters

    private static func applyFilter(_ filter: Filter?, to value: Any?) -> String {
        guard let value else { return "" }

        guard let filter else {
            return stringify(value)
        }

        switch filter {
        case .date(let format):
            guard let date = value as? Date else { return stringify(value) }
            return cachedDateFormatter(format: format).string(from: date)

        case .currency:
            guard let decimal = toDecimal(value) else { return stringify(value) }
            return CurrencyFormatter.formatDecimal(decimal)

        case .number(let digits):
            guard let decimal = toDecimal(value) else { return stringify(value) }
            return cachedNumberFormatter(digits: digits).string(from: decimal as NSDecimalNumber) ?? stringify(value)

        case .numberTrimmed(let digits):
            guard let decimal = toDecimal(value) else { return stringify(value) }
            return cachedTrimmedNumberFormatter(digits: digits).string(from: decimal as NSDecimalNumber) ?? stringify(value)

        case .markdown:
            return convertMarkdown(stringify(value))
        }
    }

    private static func toDecimal(_ value: Any) -> Decimal? {
        switch value {
        case let d as Decimal:
            return d
        case let n as NSNumber:
            return n.decimalValue
        case let s as String:
            return Decimal(string: s)
        default:
            return nil
        }
    }

    private static func stringify(_ value: Any) -> String {
        switch value {
        case let string as String:
            return string
        case let decimal as Decimal:
            return "\(decimal)"
        case let number as NSNumber:
            return number.stringValue
        case let date as Date:
            return mediumDateFormatter.string(from: date)
        default:
            return String(describing: value)
        }
    }

    private static func convertMarkdown(_ text: String) -> String {
        // Normalize line endings (\r\n is a single Character in Swift, so split(separator: "\n") won't match it)
        var result = text.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")

        // HTML-escape to prevent injection
        result = result
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        // Protect escaped asterisks from bold matching
        result = result.replacingOccurrences(of: "\\*", with: "\u{FFFD}")

        // Bold: **text** (must run before single-asterisk bold)
        result = result.replacing(boldRegex) { "<strong>\($0.1)</strong>" }

        // Bold: *text* (single asterisk also treated as bold in this project)
        result = result.replacing(italicRegex) { "<strong>\($0.1)</strong>" }

        // Restore escaped asterisks
        result = result.replacingOccurrences(of: "\u{FFFD}", with: "*")

        // List items and line breaks
        let lines = result.split(separator: "\n", omittingEmptySubsequences: false)
        var html = ""
        var inList = false
        for line in lines {
            let trimmed = line.drop(while: { $0 == " " })
            let isListItem = trimmed.hasPrefix("- ") || trimmed.hasPrefix("\u{2014} ") || trimmed.hasPrefix("\u{2014}\u{00A0}")
            if isListItem {
                let text: Substring
                if trimmed.hasPrefix("- ") {
                    text = trimmed.dropFirst(2)
                } else {
                    text = trimmed.dropFirst(2)
                }
                if !inList { html += "<ul class=\"md-list\">"; inList = true }
                html += "<li>\(text)</li>"
            } else {
                if inList { html += "</ul>"; inList = false }
                if !html.isEmpty { html += "<br>" }
                html += line
            }
        }
        if inList { html += "</ul>" }
        result = html

        return result
    }
}
