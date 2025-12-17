//
//  LoginViewModel.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//
import Foundation
import AuthenticationServices
import Combine

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService()

    func loginWithApple(
        result: Result<ASAuthorization, Error>
    ) async throws -> Profile {

        guard
            let credential = try result.get().credential as? ASAuthorizationAppleIDCredential
        else {
            throw NSError(domain: "AppleAuth", code: 0)
        }

        return try await authService.loginWithApple(credential: credential)
    }
}

