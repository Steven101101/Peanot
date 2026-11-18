//
//  OpenAIService.swift
//  Peanot
//
//  Created by Steven Thienvanich on 10/25/26.
//

import Foundation

struct OpenAIService {
    private let apiKey = Secrets.openAIAPIKey

    func generate(prompt: String) async throws -> String {
        let url = URL(
            string: "https://api.openai.com/v1/responses"
        )!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "Bearer \(apiKey)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        
        let body = OpenAIRequest(
            model: "gpt-5-mini",
            input: prompt,
            reasoning: .init(effort: "low"),
            maxOutputTokens: 1500
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            let message = String(
                data: data,
                encoding: .utf8
            ) ?? "Unknown API error"

            throw NSError(
                domain: "OpenAI",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: message
                ]
            )
        }

        let result = try JSONDecoder().decode(
            OpenAIResponse.self,
            from: data
        )
        
        print("OpenAI status:", result.status)
        print("Incomplete reason:",
              result.incompleteDetails?.reason ?? "none")

        guard result.status == "completed" else {
            throw NSError(
                domain: "OpenAI",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "OpenAI did not complete: \(result.incompleteDetails?.reason ?? result.status)"
                ]
            )
        }

        return result.output
            .flatMap(\.content!)
            .compactMap(\.text)
            .joined(separator: "\n")
    }
}


struct OpenAIRequest: Encodable {
    let model: String
    let input: String
    let reasoning: Reasoning
    let maxOutputTokens: Int

    enum CodingKeys: String, CodingKey {
        case model, input, reasoning
        case maxOutputTokens = "max_output_tokens"
    }

    struct Reasoning: Encodable {
        let effort: String
    }
}

struct OpenAIResponse: Decodable {
    let status: String
    let incompleteDetails: IncompleteDetails?
    let output: [Output]

    enum CodingKeys: String, CodingKey {
        case status
        case incompleteDetails = "incomplete_details"
        case output
    }

    struct IncompleteDetails: Decodable {
        let reason: String?
    }

    struct Output: Decodable {
        let content: [Content]?
    }

    struct Content: Decodable {
        let text: String?
    }
}
