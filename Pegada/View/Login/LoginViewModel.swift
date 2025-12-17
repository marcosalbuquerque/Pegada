//
//  LoginViewModel.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//
import Foundation
import AuthenticationServices
import Combine
import SwiftData

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthService

    init(modelContext: ModelContext) {
        self.authService = AuthService(modelContext: modelContext)
    }

    func loginWithApple(
        result: Result<ASAuthorization, Error>
    ) async throws -> ProfileEntity {

        guard
            let credential = try result.get().credential
                as? ASAuthorizationAppleIDCredential
        else {
            throw AuthError.invalidAppleToken
        }

        return try await authService.loginWithApple(
            credential: credential
        )
    }
}




