import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "ProblyAPI is usable in the Probly app only!"
    }

    app.post("test") { req async throws -> Response in
        guard let apiKey = Environment.get("TYPESAFE_API_KEY"), !apiKey.isEmpty else {
            throw Abort(.internalServerError, reason: "Пожалуйста, сообщите о проблеме разработчику. Код ошибки: ENVFETCHERROR")
        }
        
        let payload = JevTestPayload(
            model: "jev-latest",
            state: "После напряжённой недели я устал. На выходных хочу отдохнуть.",
            questions: [
                "rest": JevTestQuestion(type: "noul", instructions: "Стоит ли в этой ситуации выбрать спокойный отдых?")
            ]
        )
        
        let response = try await req.client.post("https://api.typesafe.ai/v1/systemone") { outgoingRequest in
            outgoingRequest.headers.bearerAuthorization = BearerAuthorization(token: apiKey)
            try outgoingRequest.content.encode(payload)
        }
        
        guard let body = response.body else {
            throw Abort(.badGateway, reason: "Jev не вернул ответ")
        }
        
        return Response(
            status: response.status,
            headers: ["Content-Type": "application/json"],
            body: .init(buffer: body)
        )
    }
}

struct JevTestPayload: Content {
    let model: String
    let state: String
    let questions: [String: JevTestQuestion]
}

struct JevTestQuestion: Content {
    let type: String
    let instructions: String
}
