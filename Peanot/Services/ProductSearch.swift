//
//  ProductSearch.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/24/26.
//

import Foundation

struct ProductSearch {
    private let api = PeanotAPI()

    func fetchProduct(barcode: String) async throws -> Data {
        let digits = barcode.filter(\.isNumber)

        guard (8...14).contains(digits.count) else {
            throw URLError(.badURL)
        }

        return try await api.get(
            path: "/products",
            query: [URLQueryItem(name: "upc", value: digits)]
        )
    }

    func searchProducts(matching term: String) async throws -> [Product] {
        let trimmed = term
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .prefix(200)

        guard !trimmed.isEmpty else { return [] }

        let data = try await api.get(
            path: "/products",
            query: [URLQueryItem(name: "ingr", value: String(trimmed))]
        )

        let response = try JSONDecoder().decode(
            ProductResponse.self,
            from: data
        )

        return response.hints.map(\.food)
    }
}
