//
//  File.swift
//  ProblyAPI
//
//  Created by Skr Red on 29.09.2026.
//

import Foundation

struct JevPayload: Encodable {
    let model: String
    let state: String
    let questions: [String: JevQuestion]
}

struct JevQuestion: Encodable {
    let instructions: String
    let criteria: QuestionCriteria
    
    enum CodingKeys: String, CodingKey {
        case type
        case instructions
        case criteria
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(instructions, forKey: .instructions)
        
        switch self.criteria {
        case .choice(let rawOptions):
            var options: [String: String?] = [:]
            for option in rawOptions {
                options[option.title] = option.explanation
            }
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
