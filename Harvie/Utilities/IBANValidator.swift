//
//  IBANValidator.swift
//  Harvie
//

import Foundation

struct IBANValidator {
    static func validate(_ iban: String) -> Bool {
        let cleaned = clean(iban)

        guard cleaned.count >= 5, cleaned.count <= 34 else {
            return false
        }

        // Mod97Calculator skips characters it doesn't recognize, so separators or
        // junk (e.g. "CH93-0076-...") would otherwise pass the checksum unnoticed.
        guard cleaned.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber) }) else {
            return false
        }

        let countryCode = String(cleaned.prefix(2))
        guard countryCode.allSatisfy({ $0.isLetter }) else {
            return false
        }

        let checkDigits = String(cleaned.dropFirst(2).prefix(2))
        guard checkDigits.allSatisfy({ $0.isNumber }) else {
            return false
        }

        let rearranged = String(cleaned.dropFirst(4)) + String(cleaned.prefix(4))
        let numericString = Mod97Calculator.convertToNumeric(rearranged)

        return Mod97Calculator.calculate(numericString) == 1
    }

    static func isSwissIBAN(_ iban: String) -> Bool {
        let cleaned = clean(iban)
        return cleaned.hasPrefix("CH") || cleaned.hasPrefix("LI")
    }

    static func isQRIBAN(_ iban: String) -> Bool {
        let cleaned = clean(iban)

        guard isSwissIBAN(cleaned), cleaned.count >= 9 else {
            return false
        }

        let iid = String(cleaned.dropFirst(4).prefix(5))

        guard let iidNumber = Int(iid) else {
            return false
        }

        return iidNumber >= 30000 && iidNumber <= 31999
    }

    static func format(_ iban: String) -> String {
        let cleaned = clean(iban)
        var formatted = ""

        for (index, char) in cleaned.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted.append(" ")
            }
            formatted.append(char)
        }

        return formatted
    }

    private static func clean(_ iban: String) -> String {
        iban.replacingOccurrences(of: " ", with: "").uppercased()
    }
}
