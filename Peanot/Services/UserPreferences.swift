//
//  UserPreferences.swift
//  Peanot
//
//  Created by Steven Thienvanich on 11/18/26.
//

import SwiftUI

enum UserPreferences {
    static let nameKey = "userName"
    
    static func save(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (trimmed.isEmpty) {
            UserDefaults.standard.removeObject(forKey: nameKey)
        } else {
            UserDefaults.standard.set(trimmed, forKey: nameKey)
        }
    }
    
    static func loadName() -> String {
        UserDefaults.standard.string(forKey: nameKey) ?? ""
    }
}
