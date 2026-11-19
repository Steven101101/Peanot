//
//  Analyze.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/25/26.
//

import Foundation

enum AllergenVerdict: String, Decodable {
    case avoid
    case caution
    case noListedAllergens = "no_listed_allergens"
}

struct AllergenAnalysis {
    let verdict: AllergenVerdict
    let detectedAllergens: [String]
    let explanation: String
    let highlights: [IngredientHighlight]
}

struct IngredientHighlight: Decodable {
    let phrase: String
    let type: HighlightType
}

enum HighlightType: String, Decodable {
    case confirmed
    case possible
}

private struct AllergenEvidence: Decodable {
    let verdict: AllergenVerdict
    let confirmedAllergens: [String]
    let possibleAllergens: [String]
    let explanation: String
    let highlights: [IngredientHighlight]
}

struct AnalyzeService {
    private let api = PeanotAPI()

    private struct AnalyzeRequest: Encodable {
        let ingredients: String
        let allergens: [String]
    }

    private struct AnalyzeResponse: Decodable {
        let text: String
    }

    func analyze(
        ingredients: String,
        allergens: [String]
    ) async throws -> AllergenAnalysis {

        let selected = Array(Set(allergens)).sorted()

        guard !ingredients.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            return AllergenAnalysis(
                verdict: .caution,
                detectedAllergens: [],
                explanation: "Ingredient information is unavailable.",
                highlights: []
            )
        }

        let response = try await api.post(
            path: "/analyze",
            body: AnalyzeRequest(
                ingredients: ingredients,
                allergens: selected
            )
        )

        let payload = try JSONDecoder().decode(
            AnalyzeResponse.self,
            from: response
        )

        let cleaned = payload.text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let evidence = try JSONDecoder().decode(
            AllergenEvidence.self,
            from: Data(cleaned.utf8)
        )

        let selectedLookup = Dictionary(
            uniqueKeysWithValues: selected.map {
                ($0.lowercased(), $0)
            }
        )

        let confirmed = Set(evidence.confirmedAllergens.compactMap {
            selectedLookup[$0.lowercased()]
        })

        let possible = Set(evidence.possibleAllergens.compactMap {
            selectedLookup[$0.lowercased()]
        }).subtracting(confirmed)

        return AllergenAnalysis(
            verdict: evidence.verdict,
            detectedAllergens: Array(
                confirmed.union(possible)
            ).sorted(),
            explanation: evidence.explanation,
            highlights: evidence.highlights
        )

    }
}
