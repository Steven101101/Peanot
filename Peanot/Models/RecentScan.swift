//
//  RecentScan.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/25/26.
//

import Foundation
import SwiftData

@Model
final class RecentScan {
    #Unique<RecentScan>([\.barcode])

    var barcode: String = ""
    var label: String = ""
    var brand: String?
    var imageURL: URL?
    var scannedAt: Date = Date()

    /// Raw value of `AllergenVerdict`.
    var verdictRaw: String = AllergenVerdict.caution.rawValue

    var detectedAllergens: [String] = []
    var explanation: String = ""

    /// The ingredient text the cached analysis was produced from.
    var ingredients: String?

    /// The allergen profile this scan was analyzed against. A cached verdict is
    /// only valid for this exact set, so `ResultsView` re-analyzes when the
    /// user's profile has changed since.
    var analyzedAllergens: [String] = []

    /// `IngredientHighlight` values, stored flat so SwiftData keeps them in the
    /// same record instead of promoting them to a related entity.
    var highlightPhrases: [String] = []
    var highlightTypes: [String] = []

    init(
        barcode: String,
        label: String,
        brand: String?,
        imageURL: URL?,
        ingredients: String?,
        analysis: AllergenAnalysis,
        analyzedAllergens: [String],
        scannedAt: Date = Date()
    ) {
        self.barcode = barcode
        self.label = label
        self.brand = brand
        self.imageURL = imageURL
        self.ingredients = ingredients
        self.scannedAt = scannedAt
        self.verdictRaw = analysis.verdict.rawValue
        self.detectedAllergens = analysis.detectedAllergens
        self.explanation = analysis.explanation
        self.analyzedAllergens = analyzedAllergens.sorted()
        self.highlightPhrases = analysis.highlights.map(\.phrase)
        self.highlightTypes = analysis.highlights.map(\.type.rawValue)
    }

    var verdict: AllergenVerdict {
        AllergenVerdict(rawValue: verdictRaw) ?? .caution
    }

    var highlights: [IngredientHighlight] {
        zip(highlightPhrases, highlightTypes).map { phrase, type in
            IngredientHighlight(
                phrase: phrase,
                type: HighlightType(rawValue: type) ?? .possible
            )
        }
    }

    var analysis: AllergenAnalysis {
        AllergenAnalysis(
            verdict: verdict,
            detectedAllergens: detectedAllergens,
            explanation: explanation,
            highlights: highlights
        )
    }

    /// A cached analysis is reusable only when it was produced from the
    /// allergen profile that is active now.
    func matches(allergens: Set<String>) -> Bool {
        Set(analyzedAllergens) == allergens
    }

    /// Rebuilds a `Product` good enough for `ResultsView` from the cached
    /// fields, so a recent scan opens without a network call.
    var cachedProduct: Product {
        Product(
            foodId: barcode,
            label: label,
            knownAs: nil,
            brand: brand,
            category: nil,
            categoryLabel: nil,
            foodContentsLabel: ingredients,
            image: imageURL,
            nutrients: ProductNutrients(
                calories: nil, fat: nil, saturatedFat: nil, transFat: nil,
                carbohydrates: nil, fiber: nil, sugar: nil, addedSugar: nil,
                protein: nil, cholesterol: nil, sodium: nil, calcium: nil,
                potassium: nil, iron: nil, vitaminD: nil
            ),
            servingSizes: nil,
            servingsPerContainer: nil
        )
    }
}
