//
//  RankingViewModel.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//


import Foundation
import Combine

@MainActor
final class RankingViewModel: ObservableObject {

    @Published var ranking: [RankingUser] = []
    @Published var currentUserPosition: Int?

    let currentUserId: UUID
    private let userService: UserService

    init(userService: UserService, currentUserId: UUID) {
        self.userService = userService
        self.currentUserId = currentUserId
    }

    func loadRanking() {
        userService.fetchRanking { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.mapRanking(users)
                case .failure(let error):
                    print("Erro ranking:", error)
                }
            }
        }
    }

    private func mapRanking(_ users: [RankingUserDTO]) {
        let mapped = users.enumerated().compactMap { index, user -> RankingUser? in

            guard let uuid = UUID(uuidString: user.id) else {
                print("UUID inválido:", user.id)
                return nil
            }

            return RankingUser(
                position: index + 1,
                name: user.name,
                points: user.totalSafeCarbon,
                userId: uuid,
                img_url: user.img_url ?? ""
            )
        }

        ranking = mapped

        currentUserPosition = mapped.first {
            $0.userId == currentUserId
        }?.position
    }

}
