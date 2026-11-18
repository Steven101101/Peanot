//
//  PeanotPrimaryButton.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

struct PeanotPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PeanotTypography.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, PeanotSpacing.md)
            .background(isEnabled ? PeanotColors.primary : PeanotColors.primary.opacity(0.4))
            .clipShape(
                RoundedRectangle(cornerRadius: PeanotRadius.medium)
            )
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}
