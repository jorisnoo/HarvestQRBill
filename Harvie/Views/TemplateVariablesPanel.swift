//
//  TemplateVariablesPanel.swift
//  Harvie
//

import SwiftUI

struct TemplateVariablesPanel: View {
    var onInsert: (String) -> Void

    private let categories: [(String, [TemplateVariable])] = [
        ("Invoice", [
            TemplateVariable(token: "invoice.number", label: "Number"),
            TemplateVariable(token: "invoice.amount", label: "Total Amount"),
            TemplateVariable(token: "invoice.currency", label: "Currency"),
            TemplateVariable(token: "invoice.subject", label: "Subject"),
            TemplateVariable(token: "invoice.notes", label: "Notes"),
            TemplateVariable(token: "invoice.issueDate", label: "Issue Date"),
            TemplateVariable(token: "invoice.dueDate", label: "Due Date"),
            TemplateVariable(token: "invoice.subtotal", label: "Subtotal"),
            TemplateVariable(token: "invoice.tax", label: "Tax %"),
            TemplateVariable(token: "invoice.taxAmount", label: "Tax Amount"),
            TemplateVariable(token: "invoice.discount", label: "Discount %"),
            TemplateVariable(token: "invoice.discountAmount", label: "Discount Amount"),
            TemplateVariable(token: "invoice.totalHours", label: "Total Hours")
        ]),
        ("Client", [
            TemplateVariable(token: "client.name", label: "Name"),
            TemplateVariable(token: "client.address", label: "Address")
        ]),
        ("Creditor", [
            TemplateVariable(token: "creditor.name", label: "Name"),
            TemplateVariable(token: "creditor.iban", label: "IBAN"),
            TemplateVariable(token: "creditor.street", label: "Street"),
            TemplateVariable(token: "creditor.buildingNumber", label: "Building No."),
            TemplateVariable(token: "creditor.postalCode", label: "Postal Code"),
            TemplateVariable(token: "creditor.town", label: "Town"),
            TemplateVariable(token: "creditor.country", label: "Country")
        ]),
        ("Line Items", [
            TemplateVariable(token: "#lineItems", label: "Loop Start"),
            TemplateVariable(token: "/lineItems", label: "Loop End"),
            TemplateVariable(token: "description", label: "Description"),
            TemplateVariable(token: "quantity", label: "Quantity"),
            TemplateVariable(token: "unitPrice", label: "Unit Price"),
            TemplateVariable(token: "amount", label: "Amount")
        ]),
        ("Conditionals", [
            TemplateVariable(token: "#if invoice.hasNotes", label: "If Has Notes"),
            TemplateVariable(token: "/if", label: "End If"),
            TemplateVariable(token: "#if invoice.hasTax", label: "If Has Tax"),
            TemplateVariable(token: "#if invoice.hasDiscount", label: "If Has Discount"),
            TemplateVariable(token: "#if invoice.hasSubject", label: "If Has Subject")
        ]),
        ("Labels", [
            TemplateVariable(token: "labels.invoice", label: "Invoice"),
            TemplateVariable(token: "labels.description", label: "Description"),
            TemplateVariable(token: "labels.quantity", label: "Quantity"),
            TemplateVariable(token: "labels.unitPrice", label: "Unit Price"),
            TemplateVariable(token: "labels.rate", label: "Rate"),
            TemplateVariable(token: "labels.price", label: "Price"),
            TemplateVariable(token: "labels.amount", label: "Amount"),
            TemplateVariable(token: "labels.subtotal", label: "Subtotal"),
            TemplateVariable(token: "labels.vat", label: "VAT"),
            TemplateVariable(token: "labels.discount", label: "Discount"),
            TemplateVariable(token: "labels.total", label: "Total"),
            TemplateVariable(token: "labels.totalDue", label: "Total Due"),
            TemplateVariable(token: "labels.totalHours", label: "Total Hours"),
            TemplateVariable(token: "labels.due", label: "Due"),
            TemplateVariable(token: "labels.date", label: "Date"),
            TemplateVariable(token: "labels.currency", label: "Currency"),
            TemplateVariable(token: "labels.from", label: "From"),
            TemplateVariable(token: "labels.billTo", label: "Bill To"),
            TemplateVariable(token: "labels.details", label: "Details"),
            TemplateVariable(token: "labels.iban", label: "IBAN"),
            TemplateVariable(token: "labels.paymentDetails", label: "Payment Details"),
            TemplateVariable(token: "labels.notes", label: "Notes"),
            TemplateVariable(token: "labels.re", label: "Re/Subject")
        ]),
        ("Filters", [
            TemplateVariable(token: "invoice.issueDate | date:\"dd.MM.yyyy\"", label: "Date Format"),
            TemplateVariable(token: "invoice.amount | currency", label: "Currency Format"),
            TemplateVariable(token: "quantity | numberTrimmed:1", label: "Trimmed Number Format")
        ])
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(categories, id: \.0) { category, variables in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        FlowLayout(spacing: 4) {
                            ForEach(variables) { variable in
                                Button {
                                    onInsert(variable.token)
                                } label: {
                                    Text(variable.label)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.mini)
                                .help("{{\(variable.token)}}")
                            }
                        }
                    }
                }
            }
            .padding(12)
        }
    }
}

private struct TemplateVariable: Identifiable {
    let token: String
    let label: String

    var id: String { token }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX)
        }

        return (CGSize(width: maxX, height: currentY + lineHeight), positions)
    }
}
