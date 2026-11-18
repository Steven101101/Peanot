//
//  HomeView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @AppStorage("userName") private var userName = "Steven"
    @State private var selectedAllergens = AllergenPreferences.load()
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            ScrollView {
            VStack(alignment: .leading, spacing: PeanotSpacing.lg) {
                VStack(alignment: .leading, spacing: PeanotSpacing.md) {
                    HStack {
                        Text("peanot")
                            .font(PeanotTypography.title)
                            .foregroundStyle(PeanotColors.text)

                        Spacer()

                        Circle()
                            .fill(PeanotColors.selected)
                            .frame(width: 44, height: 44)
                            .overlay {
                                Text(String(userName.first ?? "S").uppercased())
                                    .font(PeanotTypography.headline)
                                    .foregroundStyle(PeanotColors.primary)
                            }
                    }

                    Text("What are we checking, \(userName)?")
                        .font(PeanotTypography.largeTitle)
                        .foregroundStyle(PeanotColors.text)
                        .fixedSize(horizontal: false, vertical: true)
                }

                NavigationLink {
                    ScanView()
                } label: {
                    HStack(spacing: PeanotSpacing.sm) {
                        Image(systemName: "viewfinder")
                        Text("Scan a product")
                    }
                }
                .buttonStyle(PeanotPrimaryButtonStyle())
                
                PeanotCard {
                    VStack(alignment: .leading, spacing: PeanotSpacing.md) {
                        HStack {
                            Text("YOUR ALLERGY PROFILE")
                                .font(PeanotTypography.caption)
                                .tracking(0.8)
                                .foregroundStyle(PeanotColors.text.opacity(0.7))

                            Spacer()

                            NavigationLink("Edit") {
                                AllergenSelectionView(selectedAllergens: $selectedAllergens) {
                                    AllergenPreferences.save(selectedAllergens)
                                }
                            }
                            .font(PeanotTypography.caption)
                            .foregroundStyle(PeanotColors.primary)
                            .underline()
                        }

                        FlowLayout(spacing: PeanotSpacing.sm) {
                            ForEach(selectedAllergens.sorted(), id: \.self) { allergen in
                                Text(allergen)
                                    .font(PeanotTypography.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(PeanotColors.primary)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(PeanotColors.selected)
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

                RecentScansSection()

                // TODO: Temporary
                Button("Reset Onboarding") {
                    UserDefaults.standard.removeObject(forKey: AllergenPreferences.key)
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    selectedAllergens = []
                    ScanHistory.clear(in: context)
                }
                .font(PeanotTypography.caption)
                .foregroundStyle(PeanotColors.primary)
                .opacity(0.001)
                .frame(maxWidth: .infinity)
            }
            .padding(PeanotSpacing.lg)
            }
            .peanotBackground()
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear {
            selectedAllergens = AllergenPreferences.load()
        }
    }
}

#Preview {
    HomeView()
}
