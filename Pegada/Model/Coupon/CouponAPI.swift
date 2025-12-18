//
//  CouponAPI.swift
//  Pegada
//
//  Created by Joao pedro Leonel on 16/12/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case httpError(Int, String)
    case decodingError
}

struct RedeemResponse: Decodable {
    let success: Bool
    let message: String?
    let cuponRedeemed: CuponRedeemed?
    let remaining_points: Int64?
}

final class CouponAPIService {

    private let baseURL = "https://pegada-backend-production.up.railway.app/api"

    struct RedemptionRequest: Encodable {
        let user_id: String
        let cupom_id: Int
    }

    func redeemCoupon(userId: UUID, couponId: Int) async throws {
        guard let url = URL(string: "\(baseURL)/cuponRedeemed/createCuponRedeemed") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RedemptionRequest(
            user_id: userId.uuidString.lowercased(),
            cupom_id: couponId
        )

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.httpError(0, "Resposta inválida do servidor")
        }

        let decoded: RedeemResponse
        do {
            print(String(data: data, encoding: .utf8) ?? "JSON inválido")
            decoded = try JSONDecoder().decode(RedeemResponse.self, from: data)
        } catch {
            throw APIError.decodingError
        }

        // Se backend retorna erro (status >=400 ou success=false), lançamos o erro com a mensagem
        if httpResponse.statusCode >= 400 || !decoded.success {
            throw APIError.httpError(
                httpResponse.statusCode,
                decoded.message ?? "Erro desconhecido do backend"
            )
        }

        print(" Cupom resgatado com sucesso:", decoded.cuponRedeemed?.id ?? "")
    }
}
