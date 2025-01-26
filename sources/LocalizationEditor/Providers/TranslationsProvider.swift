//
//  TranslationsProvider.swift
//  LocalizationEditor
//
//  Created by Matteo Comisso on 26/1/25.
//  Copyright © 2025 Igor Kulman. All rights reserved.
//


import ChatGPTSwift
import AppKit

struct GPTTranslation: Decodable {
    let language: String
    let translation: String
}

class TranslationService {

    enum TranslationServiceError: Error {
        case parseError
    }

    private static let openAIapiKey = "OPENAI_API_KEY"

    let gptInstance: ChatGPTAPI

    init() {
        let processAPIKey = ProcessInfo.processInfo.environment[Self.openAIapiKey]
        let userDefaultsKey = UserDefaults.standard.string(forKey: Self.openAIapiKey)

        let resolvedKey = processAPIKey ?? userDefaultsKey

        guard let resolvedKey,
        !resolvedKey.isEmpty else {
            fatalError("Requires ChatGPT Key")
        }

        self.gptInstance = ChatGPTAPI(apiKey: resolvedKey)
    }

    func translate(message: String, from source: String, to destination: String) async throws -> GPTTranslation {
        let response = try await gptInstance.sendMessage(
            text: "<message>\(message)</message><from>\(source)</from><destination>\(destination)</destination>",
            model: ChatGPTModel.gpt_hyphen_4o_hyphen_mini,
            systemText: """
Please become a translator for apps. You will receive a sentence or word to translate as a <message>, please only translate from language <source> to language <destination>, without commenting or adding extra content. Maintain the same meaning that you receive in <message> to all the translations you will perform.
Return a json with keys "language" and "translation" structured as "{ language: <destination>, translation: <translation> }".
""",
            responseFormat: Components.Schemas.CreateChatCompletionRequest.response_formatPayload(_type: .json_object),
            stop: nil,
            imageData: nil
        )

        return try parse(response)
    }

    func parse(_ string: String) throws -> GPTTranslation{
        guard let data = string.data(using: .utf8) else {
            throw TranslationServiceError.parseError
        }

        let jsondecoder = JSONDecoder()
        let translation = try jsondecoder.decode(GPTTranslation.self, from: data)
        return translation
    }
}
