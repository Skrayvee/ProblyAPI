//
//  DecisionAnalysisPayload.swift
//  ProblyAPI
//
//  Created by Skr Red on 28.09.2026.
//

import Foundation

struct DecisionAnalysisPayload: Decodable {
    let state: String
    let questions: [String: QuestionPayload]
}

struct QuestionPayload: Codable {
    let instructions: String
    let criteria: QuestionCriteria
        
    enum CodingKeys: String, CodingKey {
        case instructions
        case criteria
        case type
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.instructions = try container.decode(String.self, forKey: .instructions)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "choice": self.criteria = .choice(try container.decode([String: String?].self, forKey: .criteria))
        case "noul": self.criteria = .noul(try container.decodeIfPresent(NoulCriteria.self, forKey: .criteria))
        case "score": self.criteria = .score(try container.decode([String].self, forKey: .criteria))
        default: throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Неизвестный тип вопроса: \(type)")
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(instructions, forKey: .instructions)
        
        switch self.criteria {
        case .choice(let options):
            try container.encode("choice", forKey: .type)
            try container.encode(options, forKey: .criteria)
        case .score(let levels):
            try container.encode("score", forKey: .type)
            try container.encode(levels, forKey: .criteria)
        case .noul(let explanations):
            try container.encode("noul", forKey: .type)
            try container.encodeIfPresent(explanations, forKey: .criteria)
        }
    }
}

enum QuestionCriteria {
    case choice([String: String?])
    case score([String])
    case noul(NoulCriteria?)
}

struct NoulCriteria: Codable {
    let trueExplanation: String?
    let falseExplanation: String?
    
    enum CodingKeys: String, CodingKey {
        case trueExplanation = "true"
        case falseExplanation = "false"
    }
}
