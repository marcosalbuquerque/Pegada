//
//  UserViewModel.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 17/12/25.
//
import Foundation
import SwiftData
import Combine

@MainActor
final class UserViewModel: ObservableObject {

    @Published var profile: ProfileEntity?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let profileStore: ProfileStore
    private let userService: UserService
    private let userId: UUID

    init(modelContext: ModelContext, userId: UUID, userService: UserService) {
        self.profileStore = ProfileStore(context: modelContext)
        self.userId = userId
        self.userService = userService
    }

    // MARK: - Load Profile
    func loadUserProfile() {
        do {
            self.profile = try profileStore.fetchCurrentProfile()
        } catch {
            self.errorMessage = "Erro ao carregar perfil local."
        }
    }
    
    func updateUserName(_ newName: String) async {
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Nome inválido."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await userService.updateUserName(
                userId: userId.uuidString,
                name: newName
            )

            try profileStore.updateName(userId: userId, name: newName)

            self.profile = try profileStore.fetchCurrentProfile()

        } catch {
            self.errorMessage = error.localizedDescription
            print("Erro ao atualizar nome:", error)
        }

        isLoading = false
    }

}
