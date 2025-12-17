//
//  UserService.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//

import Foundation

final class UserService {
    
    private let baseURL: String
    
    init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    // MARK: - URLs
    
    private var rankingURL: URL {
        URL(string: "\(baseURL)/user/listUsersRanking")!
    }
    
    private func profileURL(userId: String) -> URL {
        URL(string: "\(baseURL)/user/getUserProfile/\(userId)")!
    }
    
    private func updateNameURL(userId: String) -> URL {
        URL(string: "\(baseURL)/user/updateUserName/\(userId)")!
    }
    
    // URL para postar pontos
    private var postPointsURL: URL {
        URL(string: "\(baseURL)/profile/postPoints")!
    }
    
    // MARK: - Structs para Envio (Encodable)
    
    struct PointsRequest: Encodable {
        let user_id: String
        let points: Int64
        let safeCarbon: Double
    }
    
    // MARK: - Funções de Leitura
    
    func fetchRanking(completion: @escaping (Result<[RankingUserDTO], Error>) -> Void) {
        let request = URLRequest(url: rankingURL)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data else {
                completion(.failure(ServiceError.noData))
                return
            }
            
            do {
                let users = try JSONDecoder().decode([RankingUserDTO].self, from: data)
                completion(.success(users))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
    
    @MainActor
    func fetchUserProfile(
        userId: String,
        completion: @escaping (Result<UserProfileDTO, Error>) -> Void
    ) {
        let request = URLRequest(url: profileURL(userId: userId))
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(ServiceError.noData))
                }
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let user = try JSONDecoder().decode(UserProfileDTO.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        .resume()
    }
    
    // MARK: - Funções de Escrita
    
    func updateUserName(userId: String, name: String) async throws {
        var request = URLRequest(url: updateNameURL(userId: userId))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["name": name]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode
        else {
            throw ServiceError.noData
        }
        
        _ = try? JSONSerialization.jsonObject(with: data)
    }
    
    // Nova função para enviar Pontos e Carbono
    func sendUserStats(userId: UUID, points: Int64, safeCarbon: Double) async throws {
        var request = URLRequest(url: postPointsURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = PointsRequest(
            user_id: userId.uuidString.lowercased(), // Garante formato string minúsculo se necessário
            points: points,
            safeCarbon: safeCarbon
        )
        
        request.httpBody = try JSONEncoder().encode(body)
        
        print("🚀 [API] Enviando stats: \(body)")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.noData
        }
        
        print("📡 [API] Status Code envio stats: \(httpResponse.statusCode)")
        
        guard 200..<300 ~= httpResponse.statusCode else {
            // Se quiser tratar erros específicos do backend, faça aqui
            throw ServiceError.httpError(statusCode: httpResponse.statusCode)
        }
        
        print("✅ [API] Pontos e Carbono atualizados com sucesso!")
    }
}

enum ServiceError: Error {
    case noData
    case httpError(statusCode: Int)
}
