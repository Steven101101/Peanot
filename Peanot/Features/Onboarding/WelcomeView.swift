//
//  WelcomeView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: PeanotSpacing.md) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Know what's in it.")
                    .foregroundStyle(PeanotColors.text)
                Text("Before you eat it.")
                    .foregroundStyle(PeanotColors.primary)
            }
            .font(PeanotTypography.largeTitle)
            .fixedSize(horizontal: false, vertical: true)

            Text("Scan products and check restaurant menus against your allergies in seconds.")
                .font(PeanotTypography.body)
                .foregroundStyle(PeanotColors.text.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: PeanotSpacing.lg)

            Button("Get started") {
                onContinue()
            }
            .buttonStyle(PeanotPrimaryButtonStyle())
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, PeanotSpacing.lg)
        .padding(.top, PeanotSpacing.xl)
        .padding(.bottom, PeanotSpacing.lg)
        .background(PeanotColors.background)
    }
}

#Preview {
    WelcomeView {
        print("Clicked!")
    }
}
