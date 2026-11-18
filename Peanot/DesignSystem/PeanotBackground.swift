//
//  PeanotBackground.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

extension View {
    func peanotBackground() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PeanotColors.background.ignoresSafeArea())
    }
}
