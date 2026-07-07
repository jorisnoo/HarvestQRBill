//
//  IBANValidatorTests.swift
//  HarvieTests
//

import Testing
@testable import Harvie

@Suite("IBAN Validator")
struct IBANValidatorTests {

    @Test("Valid Swiss IBAN passes validation")
    func validSwissIBAN() {
        #expect(IBANValidator.validate("CH93 0076 2011 6238 5295 7"))
    }

    @Test("Valid Liechtenstein IBAN passes validation")
    func validLiechtensteinIBAN() {
        #expect(IBANValidator.validate("LI21 0881 0000 2324 013A A"))
    }

    @Test("Invalid check digits fails validation")
    func invalidCheckDigits() {
        #expect(!IBANValidator.validate("CH00 0076 2011 6238 5295 7"))
    }

    @Test("IBAN too short fails validation")
    func ibanTooShort() {
        #expect(!IBANValidator.validate("CH93"))
    }

    @Test("IBAN too long fails validation")
    func ibanTooLong() {
        let longIBAN = "CH93" + String(repeating: "0", count: 31)
        #expect(!IBANValidator.validate(longIBAN))
    }

    @Test("IBAN with separator characters fails validation")
    func ibanWithSeparatorsFails() {
        // Dashes must not be silently skipped by the mod-97 check
        #expect(!IBANValidator.validate("CH93-0076-2011-6238-5295-7"))
    }

    @Test("IBAN with non-ASCII characters fails validation")
    func ibanWithNonASCIIFails() {
        #expect(!IBANValidator.validate("CH93 0076 2011 6238 5295 é"))
    }

    @Test("Identifies Swiss IBANs")
    func identifiesSwissIBAN() {
        #expect(IBANValidator.isSwissIBAN("CH9300762011623852957"))
    }

    @Test("Identifies Liechtenstein IBANs as Swiss-compatible")
    func identifiesLiechtensteinAsSwiss() {
        #expect(IBANValidator.isSwissIBAN("LI21088100002324013AA"))
    }

    @Test("German IBAN is not Swiss")
    func germanIBANNotSwiss() {
        #expect(!IBANValidator.isSwissIBAN("DE89370400440532013000"))
    }

    @Test("Identifies QR-IBAN with IID in 30000-31999 range")
    func identifiesQRIBAN() {
        #expect(IBANValidator.isQRIBAN("CH4431999123000889012"))
        #expect(IBANValidator.isQRIBAN("CH4430000123000889012"))
    }

    @Test("Regular IBAN is not QR-IBAN")
    func regularIBANNotQRIBAN() {
        #expect(!IBANValidator.isQRIBAN("CH9300762011623852957"))
    }

    @Test("Non-Swiss IBAN is not QR-IBAN")
    func nonSwissNotQRIBAN() {
        #expect(!IBANValidator.isQRIBAN("DE89370400440532013000"))
    }

    @Test("Formats IBAN with spaces every 4 characters")
    func formatIBAN() {
        let formatted = IBANValidator.format("CH9300762011623852957")
        #expect(formatted == "CH93 0076 2011 6238 5295 7")
    }

    @Test("Format handles already-formatted IBAN")
    func formatAlreadyFormattedIBAN() {
        let formatted = IBANValidator.format("CH93 0076 2011 6238 5295 7")
        #expect(formatted == "CH93 0076 2011 6238 5295 7")
    }

    @Test("Validation is case-insensitive")
    func caseInsensitive() {
        #expect(IBANValidator.validate("ch93 0076 2011 6238 5295 7"))
    }

    @Test("Parameterized: multiple valid IBANs", arguments: [
        "CH9300762011623852957",
        "CH93 0076 2011 6238 5295 7",
        "LI21088100002324013AA"
    ])
    func multipleValidIBANs(iban: String) {
        #expect(IBANValidator.validate(iban))
    }
}
