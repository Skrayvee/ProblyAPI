import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "ProblyAPI is usable in the Probly app only!"
    }

    app.post("analysis") { req async throws in
        guard let apiUrl = Environment.get("TYPESAFE_API_URL") else {
            throw Abort(.internalServerError, reason: "Пожалуйста, сообщите о проблеме разработчику. Код ошибки: ENVURLFETCHERROR")
        }
        
        guard let apiKey = Environment.get("TYPESAFE_API_KEY") else {
            throw Abort(.internalServerError, reason: "Пожалуйста, сообщите о проблеме разработчику. Код ошибки: ENVKEYFETCHERROR")
        }
        
        let apiURI = URI(string: apiUrl)
        let payload = try req.content.decode(DecisionAnalysisPayload.self)
        
        let jevPayload = JevPayload(model: "jev-latest", state: payload.state, questions: payload.questions)
        
        let jevResponse = try await req.client.post(apiURI) { outgoing in
            outgoing.headers.bearerAuthorization = BearerAuthorization(token: apiKey)
            try outgoing.content.encode(jevPayload, as: .json)
        }
        return jevResponse
    }
}
