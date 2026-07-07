//
//  LabelEditorSheet.swift
//  Harvie
//

import SwiftUI

struct LabelEditorSheet: View {
    @Binding var labelOverrides: [String: [String: String]]?
    var baselineLabels: [String: [String: String]]?
    var keepsEmptyOverrides: Bool = false
    @State private var selectedLanguage: TemplateLanguage
    @Environment(\.dismiss) private var dismiss

    init(
        labelOverrides: Binding<[String: [String: String]]?>,
        baselineLabels: [String: [String: String]]? = nil,
        keepsEmptyOverrides: Bool = false,
        initialLanguage: TemplateLanguage = .en
    ) {
        self._labelOverrides = labelOverrides
        self.baselineLabels = baselineLabels
        self.keepsEmptyOverrides = keepsEmptyOverrides
        self._selectedLanguage = State(initialValue: initialLanguage)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            form
            Divider()
            footer
        }
        .frame(width: 550, height: 600)
    }

    private var header: some View {
        HStack {
            Text(Strings.LabelEditor.title)
                .font(.headline)
            Spacer()
            Picker("", selection: $selectedLanguage) {
                ForEach(TemplateLanguage.allCases, id: \.self) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
        }
        .padding()
    }

    private var form: some View {
        Form {
            Section(Strings.LabelEditor.templateLabels) {
                ForEach(TemplateLanguage.templateLabelKeys, id: \.self) { key in
                    LabelRow(
                        key: key,
                        language: selectedLanguage,
                        labelOverrides: $labelOverrides,
                        baselineLabels: baselineLabels,
                        keepsEmptyOverrides: keepsEmptyOverrides
                    )
                }
            }

            Section(Strings.LabelEditor.qrBillLabels) {
                ForEach(TemplateLanguage.qrBillLabelKeys, id: \.self) { key in
                    LabelRow(
                        key: key,
                        language: selectedLanguage,
                        labelOverrides: $labelOverrides,
                        baselineLabels: baselineLabels,
                        keepsEmptyOverrides: keepsEmptyOverrides
                    )
                }
            }
        }
        .formStyle(.grouped)
    }

    private var footer: some View {
        HStack {
            Button(Strings.LabelEditor.resetLanguage) {
                labelOverrides?[selectedLanguage.rawValue] = nil
                if labelOverrides?.isEmpty == true, !keepsEmptyOverrides {
                    labelOverrides = nil
                }
            }
            .disabled(labelOverrides?[selectedLanguage.rawValue] == nil)

            Spacer()

            Button(Strings.Common.done) {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
    }
}

private struct LabelRow: View {
    let key: String
    let language: TemplateLanguage
    @Binding var labelOverrides: [String: [String: String]]?
    let baselineLabels: [String: [String: String]]?
    let keepsEmptyOverrides: Bool

    private var baselineValue: String {
        baselineLabels?[language.rawValue]?[key] ?? language.defaultValue(for: key)
    }

    private var displayLabel: String {
        TemplateLanguage.en.defaultValue(for: key)
    }

    private var isCustomized: Bool {
        if let v = labelOverrides?[language.rawValue]?[key], !v.isEmpty {
            return true
        }
        return false
    }

    var body: some View {
        LabeledContent(displayLabel) {
            HStack(spacing: 4) {
                TextField("", text: binding)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 250)

                if isCustomized {
                    Button {
                        setOverride(nil)
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .help(Strings.LabelEditor.resetToDefault)
                }
            }
        }
    }

    private var binding: Binding<String> {
        Binding(
            get: { labelOverrides?[language.rawValue]?[key] ?? baselineValue },
            set: { newValue in
                let trimmed = newValue.isEmpty || newValue == baselineValue ? nil : newValue
                setOverride(trimmed)
            }
        )
    }

    private func setOverride(_ value: String?) {
        if let value {
            if labelOverrides == nil { labelOverrides = [:] }
            if labelOverrides?[language.rawValue] == nil { labelOverrides?[language.rawValue] = [:] }
            labelOverrides?[language.rawValue]?[key] = value
        } else {
            labelOverrides?[language.rawValue]?.removeValue(forKey: key)
            if labelOverrides?[language.rawValue]?.isEmpty == true {
                labelOverrides?[language.rawValue] = nil
            }
            if labelOverrides?.isEmpty == true, !keepsEmptyOverrides {
                labelOverrides = nil
            }
        }
    }
}
