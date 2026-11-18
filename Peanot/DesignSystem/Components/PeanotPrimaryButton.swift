//
//  PeanotPrimaryButton.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

struct PeanotPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PeanotTypography.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, PeanotSpacing.md)
            .background(PeanotColors.primary)
            .clipShape(
                RoundedRectangle(cornerRadius: PeanotRadius.medium)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
