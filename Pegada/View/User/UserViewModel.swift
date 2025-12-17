//
//  UserViewModel.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//

import Foundation
import Combine

final class UserViewModel: ObservableObject {

    // MARK: - Published
    @Published var profile: UserProfileDTO?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let userService: UserService
    private let userId: String

    // MARK: - Init
    init(
        userService: UserService,
        userId: String
    ) {
        self.userService = userService
        self.userId = userId
    }

    // MARK: - Load Profile
    func loadUserProfile() {
        isLoading = true
        errorMessage = nil

        userService.fetchUserProfile(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.isLoading = false

                switch result {
                case .success(let profile):
                    self.profile = profile

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Erro ao carregar perfil:", error)
                }
            }
        }
    }

    // MARK: - Update Name
    func updateUserName(_ newName: String) {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Nome inválido."
            return
        }

        isLoading = true
        errorMessage = nil

        userService.updateUserName(
            userId: userId,
            name: newName
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                self.isLoading = false

                switch result {
                case .success(let updatedProfile):
                    self.profile = updatedProfile

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Erro ao atualizar nome:", error)
                }
            }
        }
    }
}
