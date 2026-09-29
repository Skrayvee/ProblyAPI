import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "ProblyAPI is usable in the Probly app only!"
    }

    app.post("analysis") { req async throws in
        let payload = try req.content.decode(DecisionAnalysisPayload.self)
        
        var jevQuestions: [String: JevQuestion] = [:]
        for question in payload.questions {
            jevQuestions[question.id.uuidString] = JevQuestion(instructions: question.instructions, criteria: question.criteria)
        }
        let jevPayload = JevPayload(model: "jev-latest", state: payload.state, questions: jevQuestions)
        
        let jevJson = try JSONEncoder().encode(jevPayload)
        return String(decoding: jevJson, as: UTF8.self)
    }
}
