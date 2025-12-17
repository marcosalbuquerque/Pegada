//
//  CouponAPI.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 16/12/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case httpError(Int)
    case decodingError
}

final class CouponAPIService {
    // URL base extraída do seu YAML
    private let baseURL = "https://pegada-backend-production.up.railway.app/api"

    // Estrutura do corpo da requisição conforme o YAML (createCuponRedeemed)
    struct RedemptionRequest: Encodable {
        let user_id: String
        let cupom_id: String
    }

    func redeemCoupon(userId: UUID, couponId: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/cuponRedeemed/createCuponRedeemed") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // O YAML mostra que a API espera user_id e cupom_id
        let body = RedemptionRequest(user_id: userId.uuidString.lowercased(), cupom_id: couponId.uuidString.lowercased())
        
        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.httpError(0)
        }

        // Sucesso geralmente é 200 ou 201 via POST
        guard (200...299).contains(httpResponse.statusCode) else {
            // Se der 400 ou 500, provavelmente é saldo insuficiente ou erro no server
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        // Se não jogar erro, a compra foi aceita pelo backend
    }
}
