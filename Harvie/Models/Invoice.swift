//
//  Invoice.swift
//  Harvie
//

import Foundation
import SwiftUI

struct InvoicesResponse: Codable, Sendable {
    let invoices: [Invoice]
    let perPage: Int
    let totalPages: Int
    let totalEntries: Int
    let nextPage: Int?
    let previousPage: Int?
    let page: Int

    private enum CodingKeys: String, CodingKey {
        case invoices
        case perPage = "per_page"
        case totalPages = "total_pages"
        case totalEntries = "total_entries"
        case nextPage = "next_page"
        case previousPage = "previous_page"
        case page
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        invoices = try container.decode([Invoice].self, forKey: .invoices)
        perPage = try container.decode(Int.self, forKey: .perPage)
        totalPages = try container.decode(Int.self, forKey: .totalPages)
        totalEntries = try container.decode(Int.self, forKey: .totalEntries)
        nextPage = try container.decodeIfPresent(Int.self, forKey: .nextPage)
        previousPage = try container.decodeIfPresent(Int.self, forKey: .previousPage)
        page = try container.decode(Int.self, forKey: .page)
    }
}

struct Invoice: Codable, Identifiable, Hashable, Sendable {
    static func == (lhs: Invoice, rhs: Invoice) -> Bool {
        lhs.id == rhs.id && lhs.updatedAt == rhs.updatedAt
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(updatedAt)
    }

    let id: Int
    let clientKey: String
    let number: String
    let purchaseOrder: String?
    let amount: Decimal
    let dueAmount: Decimal
    let tax: Decimal?
    let taxAmount: Decimal?
    let tax2: Decimal?
    let tax2Amount: Decimal?
    let discount: Decimal?
    let discountAmount: Decimal?
    let subject: String?
    let notes: String?
    let currency: String
    let state: InvoiceState
    let periodStart: Date?
    let periodEnd: Date?
    let issueDate: Date
    let dueDate: Date
    let sentAt: Date?
    let paidAt: Date?
    let paidDate: Date?
    let closedAt: Date?
    let createdAt: Date
    let updatedAt: Date
    let client: ClientReference
    let lineItems: [LineItem]?

    var displayAmount: Decimal {
        dueAmount > 0 ? dueAmount : amount
    }

    nonisolated var effectivePaidDate: Date? {
        paidAt ?? paidDate
    }

    init(
        id: Int, clientKey: String, number: String, purchaseOrder: String? = nil,
        amount: Decimal, dueAmount: Decimal,
        tax: Decimal? = nil, taxAmount: Decimal? = nil,
        tax2: Decimal? = nil, tax2Amount: Decimal? = nil,
        discount: Decimal? = nil, discountAmount: Decimal? = nil,
        subject: String? = nil, notes: String? = nil,
        currency: String, state: InvoiceState,
        periodStart: Date? = nil, periodEnd: Date? = nil,
        issueDate: Date, dueDate: Date,
        sentAt: Date? = nil, paidAt: Date? = nil,
        paidDate: Date? = nil, closedAt: Date? = nil,
        createdAt: Date, updatedAt: Date,
        client: ClientReference, lineItems: [LineItem]? = nil
    ) {
        self.id = id
        self.clientKey = clientKey
        self.number = number
        self.purchaseOrder = purchaseOrder
        self.amount = amount
        self.dueAmount = dueAmount
        self.tax = tax
        self.taxAmount = taxAmount
        self.tax2 = tax2
        self.tax2Amount = tax2Amount
        self.discount = discount
        self.discountAmount = discountAmount
        self.subject = subject
        self.notes = notes
        self.currency = currency
        self.state = state
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.issueDate = issueDate
        self.dueDate = dueDate
        self.sentAt = sentAt
        self.paidAt = paidAt
        self.paidDate = paidDate
        self.closedAt = closedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.client = client
        self.lineItems = lineItems
    }

    private enum CodingKeys: String, CodingKey {
        case id, number, amount, tax, discount, subject, notes, currency, state
        case clientKey = "client_key"
        case purchaseOrder = "purchase_order"
        case dueAmount = "due_amount"
        case taxAmount = "tax_amount"
        case tax2
        case tax2Amount = "tax2_amount"
        case discountAmount = "discount_amount"
        case periodStart = "period_start"
        case periodEnd = "period_end"
        case issueDate = "issue_date"
        case dueDate = "due_date"
        case sentAt = "sent_at"
        case paidAt = "paid_at"
        case paidDate = "paid_date"
        case closedAt = "closed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case client
        case lineItems = "line_items"
    }

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        clientKey = try container.decode(String.self, forKey: .clientKey)
        number = try container.decode(String.self, forKey: .number)
        purchaseOrder = try container.decodeIfPresent(String.self, forKey: .purchaseOrder)
        amount = try container.decode(Decimal.self, forKey: .amount)
        dueAmount = try container.decode(Decimal.self, forKey: .dueAmount)
        tax = try container.decodeIfPresent(Decimal.self, forKey: .tax)
        taxAmount = try container.decodeIfPresent(Decimal.self, forKey: .taxAmount)
        tax2 = try container.decodeIfPresent(Decimal.self, forKey: .tax2)
        tax2Amount = try container.decodeIfPresent(Decimal.self, forKey: .tax2Amount)
        discount = try container.decodeIfPresent(Decimal.self, forKey: .discount)
        discountAmount = try container.decodeIfPresent(Decimal.self, forKey: .discountAmount)
        subject = try container.decodeIfPresent(String.self, forKey: .subject)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        currency = try container.decode(String.self, forKey: .currency)
        state = try container.decode(InvoiceState.self, forKey: .state)
        periodStart = try container.decodeIfPresent(Date.self, forKey: .periodStart)
        periodEnd = try container.decodeIfPresent(Date.self, forKey: .periodEnd)
        issueDate = try container.decode(Date.self, forKey: .issueDate)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        sentAt = try container.decodeIfPresent(Date.self, forKey: .sentAt)
        paidAt = try container.decodeIfPresent(Date.self, forKey: .paidAt)
        paidDate = try container.decodeIfPresent(Date.self, forKey: .paidDate)
        closedAt = try container.decodeIfPresent(Date.self, forKey: .closedAt)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        client = try container.decode(ClientReference.self, forKey: .client)
        lineItems = try container.decodeIfPresent([LineItem].self, forKey: .lineItems)
    }
}

enum InvoiceState: String, Codable, CaseIterable, Sendable {
    case draft
    case open
    case paid
    case closed

    var displayName: String {
        rawValue.capitalized
    }

    var color: Color {
        switch self {
        case .draft: .gray
        case .open: .orange
        case .paid: .green
        case .closed: .blue
        }
    }
}

struct LineItem: Codable, Identifiable, Sendable {
    let id: Int
    let kind: String
    let description: String?
    let quantity: Decimal
    let unitPrice: Decimal
    let amount: Decimal
    let taxed: Bool
    let taxed2: Bool
    let project: ProjectReference?

    enum CodingKeys: String, CodingKey {
        case id, kind, description, quantity, amount, taxed, taxed2, project
        case unitPrice = "unit_price"
    }
}

struct ProjectReference: Codable, Sendable {
    let id: Int
    let name: String
    let code: String?
}
