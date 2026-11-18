//
//  AllergenPreferences.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/23/26.
//

import SwiftUI

enum AllergenPreferences {
    static let key = "selectedAllergens"

    static func save(_ allergens: Set<String>) {
        UserDefaults.standard.set(
            Array(allergens).sorted(),
            forKey: key
        )
    }

    static func load() -> Set<String> {
        Set(
            UserDefaults.standard.stringArray(
                forKey: key
            ) ?? []
        )
    }
}
