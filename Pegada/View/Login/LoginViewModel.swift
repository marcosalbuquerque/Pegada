//
//  LoginViewModel.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//
import Foundation
import AuthenticationServices
import Supabase
import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {

    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService()

    func loginWithApple(result: Result<ASAuthorization, Error>) {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else {
                    throw NSError(domain: "AppleAuth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Credencial inválida"])
                }

                let profile = try await authService.loginWithApple(credential: credential)
                self.profile = profile

            } catch {
                self.errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
