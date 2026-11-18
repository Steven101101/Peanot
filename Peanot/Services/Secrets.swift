//
//  Secrets.swift
//  Peanot
//
//  Created by Steven Thienvanich on 11/18/26.
//

import Foundation

enum Secrets {
    static let openAIAPIKey = value("OPENAI_API_KEY")
    static let edamamAppID = value("EDAMAM_APP_ID")
    static let edamamAppKey = value("EDAMAM_APP_KEY")

    private static func value (_ key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty
        else {
            fatalError("Missing \(key). Create Secrets.xcconfig file and add your keys.")
        }

        return value
    }
}
