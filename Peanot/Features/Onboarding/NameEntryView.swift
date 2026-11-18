//
//  NameEntryView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 11/18/26.
//

import SwiftUI

struct NameEntryView: View {
    @Binding var name: String
    @FocusState private var isFocused: Bool
    var onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("What should we call you?")
                .font(PeanotTypography.largeTitle)
                .foregroundStyle(PeanotColors.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, PeanotSpacing.sm)

            nameField

            Spacer(minLength: PeanotSpacing.lg)

            Button(trimmedName.isEmpty ? "Skip for now" : "Continue") {
                onContinue()
            }
            .buttonStyle(PeanotPrimaryButtonStyle())
            .frame(maxWidth: .infinity)
        }
        .padding(PeanotSpacing.lg)
        .background(PeanotColors.background)
        .onAppear { isFocused = true }
    }
    
    private var nameField: some View {
        TextField("Your name", text: $name)
            .font(PeanotTypography.body.weight(.semibold))
            .foregroundStyle(PeanotColors.text)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .textContentType(.givenName)
            .submitLabel(.done)
            .focused($isFocused)
            .onSubmit(onContinue)
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

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
