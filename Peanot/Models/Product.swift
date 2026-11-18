//
//  Product.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/24/26.
//

import Foundation

struct ProductResponse: Codable {
    let text: String
    let hints: [ProductHint]
}

struct ProductHint: Codable {
    let food: Product
    let measures: [ProductMeasure]
}

struct Product: Codable {
    let foodId: String
    let label: String
    let knownAs: String?
    let brand: String?
    let category: String?
    let categoryLabel: String?
    let foodContentsLabel: String?
    let image: URL?
    let nutrients: ProductNutrients
    let servingSizes: [ProductServingSize]?
    let servingsPerContainer: Double?
}

extension Product {
    /// A placeholder product for ingredient text read off a label by OCR,
    /// where no catalog record exists.
    static func scannedLabel(ingredients: String) -> Product {
        Product(
            foodId: "scanned_label",
            label: "Scanned label",
            knownAs: nil,
            brand: nil,
            category: nil,
            categoryLabel: nil,
            foodContentsLabel: ingredients,
            image: nil,
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

struct ProductNutrients: Codable {
    let calories: Double?
    let fat: Double?
    let saturatedFat: Double?
    let transFat: Double?
    let carbohydrates: Double?
    let fiber: Double?
    let sugar: Double?
    let addedSugar: Double?
    let protein: Double?
    let cholesterol: Double?
    let sodium: Double?
    let calcium: Double?
    let potassium: Double?
    let iron: Double?
    let vitaminD: Double?

    enum CodingKeys: String, CodingKey {
        case calories = "ENERC_KCAL"
        case fat = "FAT"
        case saturatedFat = "FASAT"
        case transFat = "FATRN"
        case carbohydrates = "CHOCDF"
        case fiber = "FIBTG"
        case sugar = "SUGAR"
        case addedSugar = "SUGAR.added"
        case protein = "PROCNT"
        case cholesterol = "CHOLE"
        case sodium = "NA"
        case calcium = "CA"
        case potassium = "K"
        case iron = "FE"
        case vitaminD = "VITD"
    }
}

struct ProductServingSize: Codable {
    let uri: String
    let label: String
    let quantity: Double
}

struct ProductMeasure: Codable {
    let uri: String
    let label: String
    let weight: Double
}
