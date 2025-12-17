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

    private var rankingURL: URL {
        URL(string: "\(baseURL)/user/listUsersRanking")!
    }

    private func profileURL(userId: String) -> URL {
        URL(string: "\(baseURL)/user/getUserProfile/\(userId)")!
    }

    private func updateNameURL(userId: String) -> URL {
        URL(string: "\(baseURL)/user/updateUserName/\(userId)")!
    }

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

    // MARK: - Perfil
    func fetchUserProfile(
        userId: String,
        completion: @escaping (Result<UserProfileDTO, Error>) -> Void
    ) {
        let request = URLRequest(url: profileURL(userId: userId))

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data else {
                completion(.failure(ServiceError.noData))
                return
            }

            do {
                let user = try JSONDecoder().decode(UserProfileDTO.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }

    // MARK: - Atualizar Nome
    func updateUserName(
        userId: String,
        name: String,
        completion: @escaping (Result<UserProfileDTO, Error>) -> Void
    ) {
        var request = URLRequest(url: updateNameURL(userId: userId))
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["name": name]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data else {
                completion(.failure(ServiceError.noData))
                return
            }

            do {
                let user = try JSONDecoder().decode(UserProfileDTO.self, from: data)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }
}

enum ServiceError: Error {
    case noData
}


