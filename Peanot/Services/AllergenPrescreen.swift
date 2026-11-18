//
//  AllergenPrescreen.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/25/26.
//

import Foundation

enum AllergenPrescreen {

    enum Result {
        case clear
        case caution([String])
        case avoid([String])

        var verdict: AllergenVerdict {
            switch self {
                case .clear: .noListedAllergens
                case .caution: .caution
                case .avoid: .avoid
            }
        }

        var matchedAllergens: [String] {
            switch self {
                case .clear: []
                case .caution(let names), .avoid(let names): names
            }
        }
    }

    private static let terms: [Allergen: [String]] = [
        .milk: [
            "milk", "butter", "cream", "cheese", "whey", "casein",
            "caseinate", "lactose", "ghee", "yogurt", "curd", "custard"
        ],
        .eggs: [
            "egg", "albumen", "albumin", "mayonnaise", "meringue", "ovalbumin"
        ],
        .fish: [
            "fish", "anchovy", "anchovies", "cod", "salmon", "tuna",
            "tilapia", "haddock", "sardine", "worcestershire", "surimi"
        ],
        .shellfish: [
            "shellfish", "shrimp", "prawn", "crab", "lobster", "crayfish",
            "clam", "mussel", "oyster", "scallop", "squid", "octopus",
            "krill"
        ],
        .treeNuts: [
            "almond", "cashew", "walnut", "pecan", "pistachio", "hazelnut",
            "macadamia", "brazil nut", "pine nut", "chestnut", "praline",
            "marzipan", "nutella", "tree nut"
        ],
        .peanuts: [
            "peanut", "groundnut", "arachis", "beer nut", "monkey nut"
        ],
        .wheat: [
            "wheat", "flour", "semolina", "durum", "spelt", "farro",
            "kamut", "couscous", "bulgur", "seitan", "gluten", "bran",
            "farina", "graham"
        ],
        .soy: [
            "soy", "soya", "soybean", "edamame", "tofu", "tempeh", "miso",
            "tamari", "textured vegetable protein"
        ],
        .sesame: [
            "sesame", "tahini", "benne", "sesamol", "gingelly", "halvah",
            "hummus", "za'atar"
        ]
    ]

    private static let crossContactMarkers = [
        "may contain", "manufactured in", "manufactured on",
        "produced in", "produced on", "processed in", "processed on",
        "shared equipment", "shared facility", "shared line",
        "same equipment", "same facility", "traces of", "may include"
    ]

    private static let minimumUsefulLength = 20

    static func screen(
        ingredients: String?,
        against allergens: Set<String>
    ) -> Result {
        guard !allergens.isEmpty else { return .clear }

        let text = (ingredients ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard text.count >= minimumUsefulLength else {
            return .caution([])
        }

        let (declared, crossContact) = split(text)

        var confirmed: Set<String> = []
        var possible: Set<String> = []

        for allergen in Allergen.allCases
        where allergens.contains(allergen.rawValue) {
            guard let words = terms[allergen] else { continue }

            if words.contains(where: { declared.contains($0) }) {
                confirmed.insert(allergen.rawValue)
            } else if words.contains(where: { crossContact.contains($0) }) {
                possible.insert(allergen.rawValue)
            }
        }

        if !confirmed.isEmpty {
            return .avoid(confirmed.union(possible).sorted())
        }

        if !possible.isEmpty {
            return .caution(possible.sorted())
        }

        return .clear
    }

    private static func split(_ text: String) -> (String, String) {
        let cut = crossContactMarkers
            .compactMap { text.range(of: $0)?.lowerBound }
            .min()

        guard let cut else { return (text, "") }

        return (String(text[..<cut]), String(text[cut...]))
    }
}
