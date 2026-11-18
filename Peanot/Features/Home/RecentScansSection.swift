//
//  RecentScansSection.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/25/26.
//

import SwiftUI
import SwiftData

struct RecentScansSection: View {
    /// Newest first. The section shows a short preview; `RecentScansView` lists
    /// the full history.
    @Query(
        sort: \RecentScan.scannedAt,
        order: .reverse
    ) private var scans: [RecentScan]

    private let previewCount = 3

    var body: some View {
        VStack(alignment: .leading, spacing: PeanotSpacing.md) {
            HStack {
                Text("RECENT SCANS")
                    .font(PeanotTypography.caption)
                    .tracking(0.8)
                    .foregroundStyle(PeanotColors.text.opacity(0.7))

                Spacer()

                if scans.count > previewCount {
                    NavigationLink("See all") {
                        RecentScansView()
                    }
                    .font(PeanotTypography.caption)
                    .foregroundStyle(PeanotColors.primary)
                    .underline()
                }
            }

            VStack(spacing: PeanotSpacing.sm) {
                ForEach(scans.prefix(previewCount)) { scan in
                    NavigationLink {
                        ResultsView(recentScan: scan)
                    } label: {
                        RecentScanRow(scan: scan)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct RecentScanRow: View {
    let scan: RecentScan

    var body: some View {
        HStack(spacing: PeanotSpacing.md) {
            thumbnail

            VStack(alignment: .leading, spacing: 2) {
                Text(scan.label)
                    .font(PeanotTypography.headline)
                    .foregroundStyle(PeanotColors.text)
                    .lineLimit(1)

                Text(scan.brand ?? "Unknown brand")
                    .font(PeanotTypography.caption)
                    .foregroundStyle(PeanotColors.text.opacity(0.6))
                    .lineLimit(1)

                Text(scan.scannedAt, format: .relative(presentation: .named))
                    .font(PeanotTypography.caption)
                    .foregroundStyle(PeanotColors.text.opacity(0.5))
            }

            Spacer(minLength: PeanotSpacing.sm)

            VerdictBadge(verdict: scan.verdict)
        }
        .padding(PeanotSpacing.md)
        .background(PeanotColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: PeanotRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: PeanotRadius.medium)
                .stroke(PeanotColors.border, lineWidth: 1)
        )
    }

    private var thumbnail: some View {
        RoundedRectangle(cornerRadius: PeanotRadius.small)
            .fill(PeanotColors.selected)
            .frame(width: 48, height: 48)
            .overlay {
                if let imageURL = scan.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                            .controlSize(.small)
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(
                        RoundedRectangle(cornerRadius: PeanotRadius.small)
                    )
                } else {
                    Image(systemName: "shippingbox")
                        .foregroundStyle(PeanotColors.primary.opacity(0.6))
                }
            }
    }
}
