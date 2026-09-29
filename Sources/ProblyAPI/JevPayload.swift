//
//  File.swift
//  ProblyAPI
//
//  Created by Skr Red on 29.09.2026.
//

import Foundation

struct JevPayload: Encodable {
    var model: String
    let state: String
    let questions: [String: QuestionPayload]
}
