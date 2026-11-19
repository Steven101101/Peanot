//
//  PeanotAPI.swift
//  Peanot
//
//  Created by Steven Thienvanich on 11/18/26.
//

import Foundation

/// Errors surfaced by the Peanot backend.
enum PeanotAPIError: LocalizedError {
    case unauthorized
    case rateLimited
    case server(status: Int, message: String?)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "This copy of Peanot isn't authorized. Please update the app."

        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."

        case .server(_, let message):
            return message ?? "The server could not complete the request."

        case .invalidResponse:
            return "The server returned an unexpected response."
        }
    }
}

struct PeanotAPI {
    private let baseURL = Secrets.apiBaseURL
    private let clientToken = Secrets.clientToken

    private let session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 30
        return URLSession(configuration: configuration)
    }()

    private struct ErrorResponse: Decodable {
        let error: String
    }

    // MARK: - Requests

    func get(
        path: String,
        query: [URLQueryItem]
    ) async throws -> Data {
        guard var components = URLComponents(
            string: baseURL + path
        ) else {
            throw URLError(.badURL)
        }

        components.queryItems = query

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        return try await send(authorized(URLRequest(url: url)))
    }

    func post<Body: Encodable>(
        path: String,
        body: Body
    ) async throws -> Data {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }

        var request = authorized(URLRequest(url: url))
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = try JSONEncoder().encode(body)

        return try await send(request)
    }

    private func authorized(_ request: URLRequest) -> URLRequest {
        var request = request
        request.setValue(
            "Bearer \(clientToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return request
    }

    private func send(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw PeanotAPIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let message = try? JSONDecoder()
                .decode(ErrorResponse.self, from: data)
                .error

            switch http.statusCode {
            case 401, 403:
                throw PeanotAPIError.unauthorized

            case 429:
                throw PeanotAPIError.rateLimited

            default:
                throw PeanotAPIError.server(
                    status: http.statusCode,
                    message: message
                )
            }
        }

        return data
    }
}
