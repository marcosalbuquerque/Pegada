//
//  AuthService.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//

import Foundation
import Supabase
import AuthenticationServices


@MainActor
class AuthService {
    
    private let client = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
    
    func loginWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> Profile {
        let idToken = try extractIdToken(from: credential)
        
        try await signInWithSupabase(idToken: idToken)
        try await updateUserMetadataIfNeeded(credential: credential)
        
        let userId = try await getCurrentUserId()
        let profile = try await fetchProfile(userId: userId)
        
        return profile
    }
    
    private func extractIdToken(from credential: ASAuthorizationAppleIDCredential) throws -> String {
        guard
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8)
        else {
            throw NSError(domain: "AppleAuth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Token inválido"])
        }
        return idToken
    }
    
    private func signInWithSupabase(idToken: String) async throws {
        let _ = try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(provider: .apple, idToken: idToken)
        )
    }
    
    private func updateUserMetadataIfNeeded(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let fullName = credential.fullName else { return }

        let name = [
            fullName.givenName,
            fullName.middleName,
            fullName.familyName
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        let _ = try await client.auth.update(
            user: UserAttributes(data: ["name": .string(name)])
        )
    }

    private func getCurrentUserId() async throws -> UUID {
        let session = try await client.auth.session
        return session.user.id
    }
    
    private func fetchProfile(userId: UUID) async throws -> Profile {
        var profile: Profile? = nil
        var retries = 0

        while profile == nil && retries < 10 {
            let response = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .execute()

            profile = try JSONDecoder().decode([Profile].self, from: response.data).first

            if profile == nil {
                try await Task.sleep(nanoseconds: 500_000_000)
                retries += 1
            }
        }

        guard let finalProfile = profile else {
            throw NSError(domain: "ProfileError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Profile não encontrado"])
        }

        return finalProfile
    }




}
