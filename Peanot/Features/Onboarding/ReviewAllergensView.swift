//
//  ReviewAllergensView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

struct ReviewAllergensView: View {
    let selectedAllergens: Set<String>
    var onContinue: () -> Void
    var onChangeAllergens: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Review Your Allergens")
                .font(PeanotTypography.largeTitle)
                .foregroundStyle(PeanotColors.text)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, PeanotSpacing.sm)

            if selectedAllergens.isEmpty {
                Text("You haven't selected any allergens.")
                    .foregroundStyle(.secondary)
            } else {
                VStack {
                    PeanotCard {
                        VStack(alignment: .leading, spacing: PeanotSpacing.md) {
                            HStack {
                                Text("YOU PICKED")
                                    .font(.system(size: 15, weight: .bold))
                                    .tracking(0.8)
                                    .foregroundStyle(PeanotColors.text.opacity(0.7))

                                Spacer()

                                Button("Change") {
                                    onChangeAllergens()
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(PeanotColors.primary)
                                .underline()
                            }

                            FlowLayout(spacing: PeanotSpacing.sm) {
                                ForEach(selectedAllergens.sorted(), id: \.self) { allergen in
                                    Text(allergen)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 12)
                                        .background(PeanotColors.primary)
                                        .clipShape(Capsule())
                                }
                            }

                        }
                        .padding(PeanotSpacing.sm)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: PeanotRadius.large)
                            .stroke(PeanotColors.border, lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    Button("Finish Setup") {
                        onContinue()
                    }
                    .buttonStyle(PeanotPrimaryButtonStyle())
                }
            }
        }
        .padding(PeanotSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(PeanotColors.background)
    }
}

#Preview {
    let selectAllergens: Set<String> = ["Peanut", "Apple", "Milk", "Cheese", "Bob"]
    
    ReviewAllergensView(selectedAllergens: selectAllergens, onContinue: { print("Clicked!") }, onChangeAllergens: { print("Change Allergens") })
}
