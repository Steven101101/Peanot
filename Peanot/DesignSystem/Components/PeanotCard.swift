//
//  PeanotCard.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

struct PeanotCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(PeanotSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PeanotColors.surface)
            .clipShape(
                RoundedRectangle(cornerRadius: PeanotRadius.large)
            )
    }
}
