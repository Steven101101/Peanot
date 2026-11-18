//
//  OnboardingView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    @State private var step = 0
    @State private var name: String = ""
    @State private var selectedAllergens: Set<String> = []

    private let totalSteps = 4

    var body: some View {
        VStack(spacing: 24) {
            ProgressView(
                value: Double(step + 1),
                total: Double(totalSteps)
            )
            .tint(PeanotColors.primary)
            .padding(.horizontal)

            Group {
                switch step {
                case 0:
                    WelcomeView {
                        step += 1
                    }
                case 1:
                    NameEntryView(name: $name) {
                        step += 1
                    }
                case 2:
                    AllergenSelectionView (
                        selectedAllergens: $selectedAllergens
                    ) {
                        step += 1
                    }
                default:
                    ReviewAllergensView (
                        selectedAllergens: selectedAllergens,
                        onContinue: {
                            finishOnboarding()
                        },
                        onChangeAllergens: {
                            step -= 1
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background {
            PeanotColors.background
                .ignoresSafeArea()
        }
    }

    private func finishOnboarding() {
        UserPreferences.save(name: name)
        AllergenPreferences.save(selectedAllergens)
        hasCompletedOnboarding = true
    }
}
