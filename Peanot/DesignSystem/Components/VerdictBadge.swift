//
//  VerdictBadge.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/25/26.
//

import SwiftUI

extension AllergenVerdict {
    var badgeLabel: String {
        switch self {
        case .avoid: "Avoid"
        case .caution: "Caution"
        case .noListedAllergens: "No Match"
        }
    }

    var badgeSymbol: String {
        switch self {
        case .avoid: "xmark"
        case .caution: "exclamationmark.triangle.fill"
        case .noListedAllergens: "checkmark"
        }
    }

    var badgeText: Color {
        switch self {
        case .avoid: PeanotColors.avoidText
        case .caution: PeanotColors.cautionText
        case .noListedAllergens: PeanotColors.safeText
        }
    }

    var badgeFill: Color {
        switch self {
        case .avoid: PeanotColors.avoidFill
        case .caution: PeanotColors.cautionFill
        case .noListedAllergens: PeanotColors.safeFill
        }
    }
}

struct VerdictBadge: View {
    let verdict: AllergenVerdict

    var body: some View {
        HStack(spacing: PeanotSpacing.xs) {
            Image(systemName: verdict.badgeSymbol)
                .font(.system(size: 10, weight: .bold))

            Text(verdict.badgeLabel)
                .font(PeanotTypography.caption)
                .fontWeight(.bold)
        }
        .foregroundStyle(verdict.badgeText)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(verdict.badgeFill)
        .clipShape(Capsule())
        .accessibilityLabel("Verdict: \(verdict.badgeLabel)")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: PeanotSpacing.sm) {
        VerdictBadge(verdict: .avoid)
        VerdictBadge(verdict: .caution)
        VerdictBadge(verdict: .noListedAllergens)
    }
    .padding()
}
