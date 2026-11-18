//
//  ScanHistory.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/25/26.
//

import Foundation
import SwiftData

enum ScanHistory {
    /// Scans kept on device. Older scans are pruned as new ones arrive.
    static let limit = 20

    /// Records a completed analysis. Re-scanning a product updates the existing
    /// entry and moves it to the top rather than adding a duplicate.
    @MainActor
    static func record(
        barcode: String,
        product: Product,
        analysis: AllergenAnalysis,
        analyzedAllergens: Set<String>,
        in context: ModelContext
    ) {
        let descriptor = FetchDescriptor<RecentScan>(
            predicate: #Predicate { $0.barcode == barcode }
        )

        if let existing = try? context.fetch(descriptor).first {
            existing.label = product.label
            existing.brand = product.brand
            existing.imageURL = product.image
            existing.ingredients = product.foodContentsLabel
            existing.scannedAt = Date()
            existing.verdictRaw = analysis.verdict.rawValue
            existing.detectedAllergens = analysis.detectedAllergens
            existing.explanation = analysis.explanation
            existing.analyzedAllergens = analyzedAllergens.sorted()
            existing.highlightPhrases = analysis.highlights.map(\.phrase)
            existing.highlightTypes = analysis.highlights.map(\.type.rawValue)
        } else {
            context.insert(
                RecentScan(
                    barcode: barcode,
                    label: product.label,
                    brand: product.brand,
                    imageURL: product.image,
                    ingredients: product.foodContentsLabel,
                    analysis: analysis,
                    analyzedAllergens: analyzedAllergens.sorted()
                )
            )
        }

        prune(in: context)
        save(context)
    }

    @MainActor
    static func delete(_ scan: RecentScan, in context: ModelContext) {
        context.delete(scan)
        save(context)
    }

    @MainActor
    static func clear(in context: ModelContext) {
        try? context.delete(model: RecentScan.self)
        save(context)
    }

    /// Drops the oldest scans beyond `limit`.
    @MainActor
    private static func prune(in context: ModelContext) {
        var descriptor = FetchDescriptor<RecentScan>(
            sortBy: [SortDescriptor(\.scannedAt, order: .reverse)]
        )
        descriptor.fetchLimit = nil

        guard let scans = try? context.fetch(descriptor),
              scans.count > limit
        else { return }

        for scan in scans.dropFirst(limit) {
            context.delete(scan)
        }
    }

    @MainActor
    private static func save(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save scan history:", error)
        }
    }
}
