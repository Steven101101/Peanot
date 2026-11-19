//
//  Secrets.swift
//  Peanot
//
//  Created by Steven Thienvanich on 11/18/26.
//

import Foundation

enum Secrets {
    static let apiBaseURL = "\(value("PEANOT_API_SCHEME"))://\(value("PEANOT_API_HOST"))"

    static let clientToken = value("PEANOT_CLIENT_TOKEN")

    private static func value (_ key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String, !value.isEmpty
        else {
            fatalError("Missing \(key). Create Secrets.xcconfig file and add your keys.")
        }

        return value
    }
}
