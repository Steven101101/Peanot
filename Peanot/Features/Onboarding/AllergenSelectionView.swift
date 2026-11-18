//
//  AllergenSelectionView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

struct AllergenSelectionView: View {
    @Binding var selectedAllergens: Set<String>
    @Environment(\.dismiss) private var dismiss
    var onContinue: () -> Void

    @State private var customAllergen = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Which of these do you avoid?")
                .font(PeanotTypography.largeTitle)
                .foregroundStyle(PeanotColors.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, PeanotSpacing.sm)

            Text("The FDA's top 9 food allergens. Pick all that apply, or add your own.")
                .font(PeanotTypography.caption)
                .foregroundStyle(PeanotColors.text.opacity(0.75))
                .padding(.bottom, PeanotSpacing.md)

            ScrollView {
                VStack(spacing: PeanotSpacing.sm) {
                    ForEach(Allergen.allCases) { allergen in
                        AllergenRow(
                            title: allergen.rawValue,
                            isSelected: selectedAllergens.contains(allergen.rawValue)
                        ) {
                            toggle(allergen.rawValue)
                        }
                    }

                    ForEach(customAllergens, id: \.self) { allergen in
                        AllergenRow(
                            title: allergen,
                            isSelected: true,
                            onRemove: { selectedAllergens.remove(allergen) }
                        ) {
                            toggle(allergen)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
            .scrollIndicators(.hidden)

            customAllergenField
                .padding(.top, PeanotSpacing.sm)

            Button(continueTitle) {
                onContinue()
                dismiss()
            }
            .buttonStyle(PeanotPrimaryButtonStyle())
            .disabled(selectedAllergens.isEmpty)
            .frame(maxWidth: .infinity)
            .padding(.top, PeanotSpacing.md)
        }
        .padding(PeanotSpacing.lg)
        .background(PeanotColors.background)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Custom field

    private var customAllergenField: some View {
        HStack(spacing: PeanotSpacing.sm) {
            TextField("Add your own", text: $customAllergen)
                .font(PeanotTypography.body.weight(.semibold))
                .foregroundStyle(PeanotColors.text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .onSubmit(addCustomAllergen)

            Button(action: addCustomAllergen) {
                Image(systemName: "plus")
                    .font(.body.weight(.bold))
                    .foregroundStyle(canAddCustomAllergen ? PeanotColors.primary : PeanotColors.primary.opacity(0.3))
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .disabled(!canAddCustomAllergen)
            .accessibilityLabel("Add allergen")
        }
        .padding(.horizontal, PeanotSpacing.lg)
        .padding(.vertical, PeanotSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PeanotRadius.medium)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PeanotRadius.medium)
                .strokeBorder(PeanotColors.primary.opacity(0.4), lineWidth: 2)
        )
    }

    // MARK: - Helpers

    private var customAllergens: [String] {
        let standard = Set(Allergen.allCases.map(\.rawValue))
        return selectedAllergens.filter { !standard.contains($0) }.sorted()
    }

    private var trimmedCustomAllergen: String {
        customAllergen.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAddCustomAllergen: Bool {
        let trimmed = trimmedCustomAllergen
        guard !trimmed.isEmpty else { return false }
        return !selectedAllergens.contains { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
    }

    private func addCustomAllergen() {
        guard canAddCustomAllergen else { return }

        let trimmed = trimmedCustomAllergen
        let title = Allergen.allCases
            .first { $0.rawValue.caseInsensitiveCompare(trimmed) == .orderedSame }?
            .rawValue ?? trimmed

        selectedAllergens.insert(title)
        customAllergen = ""
    }

    private var continueTitle: String {
        switch selectedAllergens.count {
            case 0:  return "Please select at least one allergen"
            case 1:  return "Continue with 1 allergen"
            default: return "Continue with \(selectedAllergens.count) allergens"
        }
    }

    private func toggle(_ allergen: String) {
        if selectedAllergens.contains(allergen) {
            selectedAllergens.remove(allergen)
        } else {
            selectedAllergens.insert(allergen)
        }
    }
}

// MARK: - Row

private struct AllergenRow: View {
    let title: String
    let isSelected: Bool
    var onRemove: (() -> Void)? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(PeanotTypography.body.weight(.semibold))
                    .foregroundStyle(PeanotColors.text)

                Spacer()

                if let onRemove {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(PeanotColors.primary.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove \(title)")
                } else {
                    checkbox
                }
            }
            .padding(.horizontal, PeanotSpacing.lg)
            .padding(.vertical, PeanotSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: PeanotRadius.medium)
                    .fill(isSelected ? PeanotColors.primary.opacity(0.15) : .white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PeanotRadius.medium)
                    .strokeBorder(PeanotColors.primary, lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: 0.15), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var checkbox: some View {
        RoundedRectangle(cornerRadius: PeanotRadius.small - 2)
            .fill(isSelected ? PeanotColors.primary : .clear)
            .overlay(
                RoundedRectangle(cornerRadius: PeanotRadius.small - 2)
                    .strokeBorder(PeanotColors.primary.opacity(isSelected ? 0 : 0.4),
                                  lineWidth: 2)
            )
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 26, height: 26)
    }
}
