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

    private let baseURL = "https://pegada-backend-production.up.railway.app/api"

    struct RedemptionRequest: Encodable {
        let user_id: String
        let cupom_id: Int
    }

    func redeemCoupon(userId: UUID, couponId: Int) async throws {
        print("🚀 [API] Iniciando resgate")
        print("👤 userId:", userId)
        print("🎟️ couponId:", couponId)

        guard let url = URL(string: "\(baseURL)/cuponRedeemed/createCuponRedeemed") else {
            print("❌ [API] URL inválida")
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RedemptionRequest(
            user_id: userId.uuidString.lowercased(),
            cupom_id: couponId
        )

        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData

        print("📦 [API] Body JSON:")
        print(String(data: jsonData, encoding: .utf8) ?? "JSON inválido")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [API] Resposta inválida")
            throw APIError.httpError(0)
        }

        print("📡 [API] Status code:", httpResponse.statusCode)

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ [API] Erro HTTP:", httpResponse.statusCode)
            throw APIError.httpError(httpResponse.statusCode)
        }

        print("✅ [API] Cupom resgatado com sucesso")
    }
}
