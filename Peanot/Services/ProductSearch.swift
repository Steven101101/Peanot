//
//  ProductSearch.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/24/26.
//

import Foundation

struct ProductSearch {
    private let appId = Secrets.edamamAppID
    private let appKey = Secrets.edamamAppKey

    func fetchProduct(barcode: String) async throws -> Data {
        try await fetch(query: URLQueryItem(name: "upc", value: barcode))
    }

    func searchProducts(matching term: String) async throws -> [Product] {
        let data = try await fetch(
            query: URLQueryItem(name: "ingr", value: term),
            extra: [URLQueryItem(name: "nutrition-type", value: "logging")]
        )

        let response = try JSONDecoder().decode(
            ProductResponse.self,
            from: data
        )

        return response.hints.map(\.food)
    }

    private func fetch(
        query: URLQueryItem,
        extra: [URLQueryItem] = []
    ) async throws -> Data {
        var components = URLComponents(
            string: "https://api.edamam.com/api/food-database/v2/parser"
        )!

        components.queryItems = [
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            query
        ] + extra

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}
