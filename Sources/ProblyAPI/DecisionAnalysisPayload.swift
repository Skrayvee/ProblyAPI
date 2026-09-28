//
//  DecisionAnalysisPayload.swift
//  ProblyAPI
//
//  Created by Skr Red on 28.09.2026.
//

import Foundation

struct DecisionAnalysisPayload: Decodable {
    let state: String
    let questions: [QuestionPayload]
}

struct QuestionPayload: Decodable {
    let id: UUID
    let instructions: String
    let criteria: QuestionCriteria
    
    enum CodingKeys: String, CodingKey {
        case id
        case instructions
        case criteria
        case type
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.instructions = try container.decode(String.self, forKey: .instructions)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "choice": self.criteria = .choice(try container.decode([ChoiceOption].self, forKey: .criteria))
        case "noul": self.criteria = .noul(try container.decodeIfPresent(NoulCriteria.self, forKey: .criteria))
        case "score": self.criteria = .score(try container.decode([String].self, forKey: .criteria))
        default: throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Неизвестный тип вопроса: \(type)")
        }
    }
}

enum QuestionCriteria {
    case choice([ChoiceOption])
    case score([String])
    case noul(NoulCriteria?)
}

struct ChoiceOption: Decodable {
    let title: String
    let explanation: String?
}

struct NoulCriteria: Decodable {
    let trueExplanation: String?
    let falseExplanation: String?
    
    enum CodingKeys: String, CodingKey {
        case trueExplanation = "true"
        case falseExplanation = "false"
    }
}
