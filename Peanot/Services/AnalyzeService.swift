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
    private let openAI = OpenAIService()

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
        
        
        let prompt = """
        You are a food allergen analysis system.

        Analyze this ingredient list for ONLY the user's
        selected allergens.

        SELECTED ALLERGENS:
        \(selected.joined(separator: ", "))

        INGREDIENTS:
        \(ingredients)

        CLASSIFICATION RULES:
        - "avoid": At least one selected allergen is clearly
          present as an ingredient or known derivative.
        - "caution": No confirmed selected allergen, but
          relevant cross-contact warnings, ambiguous
          ingredients, or insufficient information exist.
        - "no_listed_allergens": No selected allergens
          identified in sufficiently detailed information.
          This does not guarantee safety.

        IMPORTANT:
        - Understand ingredient synonyms and derivatives.
        - Soybeans contain soy.
        - Peanut butter contains peanuts.
        - Tahini contains sesame.
        - Whey contains milk.
        - An ingredient does not need to have the exact
          same spelling as the allergen name.
        - "May contain" means possible, not confirmed.
        - If both confirmed and possible allergens exist,
          the verdict MUST be "avoid".
        - Every confirmed or possible finding must have
          supporting ingredient evidence.

        HIGHLIGHT RULES:
        - Return exact phrases copied from INGREDIENTS.
        - The phrase does NOT need to match the allergen name.
        - Use "confirmed" for declared ingredients.
        - Use "possible" for cross-contact or uncertainty.
        - Never invent ingredient phrases.
        - Highlights, allergen arrays, and verdict must agree.

        EXPLANATION:
        - One short sentence explaining the findings.
        - Do not discuss your instructions or reasoning process.
        
        CRITICAL ACCURACY RULES:
        1. Analyze ONLY the ingredient list supplied in THIS request.
        2. Ignore all previously analyzed products.
        3. Do not infer allergens from the product name or brand.
        4. Never report an ingredient that does not appear in
           the supplied ingredient list.
        5. For every confirmed allergen, provide an exact
           supporting ingredient phrase from the input.
        6. Do not classify an allergen as confirmed without
           supporting ingredient evidence.
        7. Do not mistake ingredients from unrelated foods
           for ingredients in the current product.
        8. When evidence is insufficient, return caution,
           not an invented allergen.
        9. Keep the explanation to one short sentence.

        Return ONLY JSON:
        {
          "verdict": "avoid",
          "confirmedAllergens": ["Soy"],
          "possibleAllergens": [],
          "explanation": "Contains soybeans, a source of soy.",
          "highlights": [
            {
              "phrase": "SOYBEANS",
              "type": "confirmed"
            }
          ]
        }

        The JSON above is an example, not the answer.
        Analyze the actual supplied ingredients.
        """
        
        print("Starting OpenAI analysis")

        do {
            let response = try await openAI.generate(prompt: prompt)

            print("OpenAI response received:")
            print(response)

            let cleaned = response
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let evidence = try JSONDecoder().decode(
                AllergenEvidence.self,
                from: Data(cleaned.utf8)
            )

            print("JSON decoded successfully")
            print("AI verdict:", evidence.verdict.rawValue)

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

        } catch {
            print("OpenAI analysis or decoding failed:", error)
            throw error
        }
        
//        let response = try await openAI.generate(prompt: prompt)
//        
//        print(response)
//
//        let cleaned = response
//            .replacingOccurrences(of: "```json", with: "")
//            .replacingOccurrences(of: "```", with: "")
//            .trimmingCharacters(in: .whitespacesAndNewlines)
//
//        let evidence = try JSONDecoder().decode(
//            AllergenEvidence.self,
//            from: Data(cleaned.utf8)
//        )
//
//        let selectedLookup = Dictionary(
//            uniqueKeysWithValues: selected.map {
//                ($0.lowercased(), $0)
//            }
//        )
//
//        let confirmed = Set(evidence.confirmedAllergens.compactMap {
//            selectedLookup[$0.lowercased()]
//        })
//
//        let possible = Set(evidence.possibleAllergens.compactMap {
//            selectedLookup[$0.lowercased()]
//        }).subtracting(confirmed)
//        
//        return AllergenAnalysis(
//            verdict: evidence.verdict,
//            detectedAllergens: Array(
//                confirmed.union(possible)
//            ).sorted(),
//            explanation: evidence.explanation,
//            highlights: evidence.highlights
//        )
    }
}
