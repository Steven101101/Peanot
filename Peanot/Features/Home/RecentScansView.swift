//
//  RecentScansView.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/25/26.
//

import SwiftUI
import SwiftData

struct RecentScansView: View {
    @Environment(\.modelContext) private var context

    @Query(
        sort: \RecentScan.scannedAt,
        order: .reverse
    ) private var scans: [RecentScan]

    @State private var isConfirmingClear = false

    var body: some View {
        Group {
            if scans.isEmpty {
                ContentUnavailableView(
                    "No Scans Yet",
                    systemImage: "viewfinder",
                )
            } else {
                List {
                    ForEach(scans) { scan in
                        NavigationLink {
                            ResultsView(recentScan: scan)
                        } label: {
                            RecentScanRow(scan: scan)
                        }
                        .listRowInsets(
                            EdgeInsets(
                                top: PeanotSpacing.xs,
                                leading: PeanotSpacing.md,
                                bottom: PeanotSpacing.xs,
                                trailing: PeanotSpacing.md
                            )
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .peanotBackground()
        .navigationTitle("Recent Scans")
        .toolbar {
            if !scans.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear", role: .destructive) {
                        isConfirmingClear = true
                    }
                    .font(PeanotTypography.caption)
                }
            }
        }
        .confirmationDialog(
            "Clear all recent scans?",
            isPresented: $isConfirmingClear,
            titleVisibility: .visible
        ) {
            Button("Clear All", role: .destructive) {
                ScanHistory.clear(in: context)
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            ScanHistory.delete(scans[index], in: context)
        }
    }
}
