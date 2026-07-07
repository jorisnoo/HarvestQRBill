//
//  QRBillService.swift
//  Harvie
//

import Foundation
import CoreImage

struct QRBillService {
    nonisolated static func isCurrencySupported(_ currency: String) -> Bool {
        ["CHF", "EUR"].contains(currency.uppercased())
    }

    enum ValidationError: Error, LocalizedError {
        case invalidIBAN
        case qrIBANNotSupported
        case invalidCreditorAddress
        case invalidAmount
        case invalidCurrency
        case invalidReference
        case messageTooLong

        var errorDescription: String? {
            switch self {
            case .invalidIBAN:
                return Strings.Errors.invalidIBAN
            case .qrIBANNotSupported:
                return Strings.Errors.qrIBANNotSupported
            case .invalidCreditorAddress:
                return Strings.Errors.invalidCreditorAddress
            case .invalidAmount:
                return Strings.Errors.invalidAmount
            case .invalidCurrency:
                return Strings.Errors.invalidCurrency
            case .invalidReference:
                return Strings.Errors.invalidReference
            case .messageTooLong:
                return Strings.Errors.messageTooLong
            }
        }
    }

    func createQRBillData(
        invoice: Invoice,
        creditorInfo: CreditorInfo,
        debtorAddress: StructuredAddress? = nil,
        language: TemplateLanguage = .en,
        labelOverrides: [String: [String: String]]? = nil
    ) throws -> QRBillData {
        guard IBANValidator.validate(creditorInfo.iban) else {
            throw ValidationError.invalidIBAN
        }

        // QR-IBAN requires QRR reference type, which we don't support (SCOR only)
        if IBANValidator.isQRIBAN(creditorInfo.iban) {
            throw ValidationError.qrIBANNotSupported
        }

        guard creditorInfo.isValid else {
            throw ValidationError.invalidCreditorAddress
        }

        let currency = invoice.currency.uppercased()
        guard ["CHF", "EUR"].contains(currency) else {
            throw ValidationError.invalidCurrency
        }

        let reference = CreditorReferenceGenerator.generate(from: invoice.number)

        return QRBillData(
            creditorIBAN: creditorInfo.iban.replacingOccurrences(of: " ", with: "").uppercased(),
            creditorAddress: creditorInfo.structuredAddress,
            amount: invoice.dueAmount,
            currency: currency,
            // The spec requires postal code and town when a debtor is present; an
            // incomplete address (e.g. client fetch failed) would make scanners reject
            // the code. Omit the debtor instead — the renderer draws the blank field.
            debtorAddress: debtorAddress?.isValid == true ? debtorAddress : nil,
            reference: reference,
            unstructuredMessage: "\(language.resolvedQRBillLabels(overrides: labelOverrides).invoice) \(invoice.number)",
            billingInfo: nil
        )
    }

    func generateQRCodeImage(from data: QRBillData, size: CGFloat = 500) -> CGImage? {
        let payload = data.generatePayload()

        guard let payloadData = payload.data(using: .utf8) else {
            return nil
        }

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }

        filter.setValue(payloadData, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else {
            return nil
        }

        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        return context.createCGImage(scaledImage, from: scaledImage.extent)
    }

    private static let minAmount: Decimal = 0.01
    private static let maxAmount: Decimal = 999_999_999.99
    private static let maxMessageLength = 140

    func validate(_ data: QRBillData) -> [ValidationError] {
        var errors: [ValidationError] = []

        if !IBANValidator.validate(data.creditorIBAN) {
            errors.append(.invalidIBAN)
        }

        if IBANValidator.isQRIBAN(data.creditorIBAN) {
            errors.append(.qrIBANNotSupported)
        }

        if !data.creditorAddress.isValid {
            errors.append(.invalidCreditorAddress)
        }

        if let amount = data.amount {
            if amount < Self.minAmount || amount > Self.maxAmount {
                errors.append(.invalidAmount)
            }
        }

        if !["CHF", "EUR"].contains(data.currency) {
            errors.append(.invalidCurrency)
        }

        if let reference = data.reference,
           !reference.isEmpty,
           !CreditorReferenceGenerator.validate(reference) {
            errors.append(.invalidReference)
        }

        // Combined message and billing info must not exceed 140 characters
        let messageLength = (data.unstructuredMessage ?? "").count + (data.billingInfo ?? "").count
        if messageLength > Self.maxMessageLength {
            errors.append(.messageTooLong)
        }

        return errors
    }
}
