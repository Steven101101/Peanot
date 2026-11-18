//
//  Allergen.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import Foundation

enum Allergen: String, CaseIterable, Identifiable {
    case milk = "Milk"
    case eggs = "Eggs"
    case fish = "Fish"
    case shellfish = "Shellfish"
    case treeNuts = "Tree nuts"
    case peanuts = "Peanuts"
    case wheat = "Wheat"
    case soy = "Soy"
    case sesame = "Sesame"

    var id: String { rawValue }
}
