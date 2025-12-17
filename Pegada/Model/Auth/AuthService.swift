//
//  AuthService.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//
//

import Foundation
import Supabase
import AuthenticationServices
import SwiftData

@MainActor
final class AuthService {

    // MARK: - Supabase
    private let client = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )

    // MARK: - SwiftData
    private let profileStore: ProfileStore
    

    init(modelContext: ModelContext) {
        self.profileStore = ProfileStore(context: modelContext)
    }

    func loginWithApple(
        credential: ASAuthorizationAppleIDCredential
    ) async throws -> ProfileEntity {

        let idToken = try extractIdToken(from: credential)

        try await signInWithSupabase(idToken: idToken)
        try await updateUserMetadataIfNeeded(credential: credential)
        let userId = try await getCurrentUserId()
        let profileDTO = try await fetchProfile(userId: userId)
        try profileStore.deleteAll()
        try profileStore.save(profile: profileDTO)
        guard let profile = try profileStore.fetchCurrentProfile() else {
            throw AuthError.profileNotSaved
        }
        return profile
    }

    func logout() async throws {
        try await client.auth.signOut()
        try profileStore.deleteAll()
    }

    // MARK: - Private
    private func extractIdToken(
        from credential: ASAuthorizationAppleIDCredential
    ) throws -> String {

        guard
            let tokenData = credential.identityToken,
            let token = String(data: tokenData, encoding: .utf8)
        else {
            throw AuthError.invalidAppleToken
        }

        return token
    }

    private func signInWithSupabase(idToken: String) async throws {
        try await client.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .apple,
                idToken: idToken
            )
        )
    }

    private func updateUserMetadataIfNeeded(
        credential: ASAuthorizationAppleIDCredential
    ) async throws {

        guard let fullName = credential.fullName else { return }

        let name = [
            fullName.givenName,
            fullName.middleName,
            fullName.familyName
        ]
        .compactMap { $0 }
        .joined(separator: " ")

        try await client.auth.update(
            user: UserAttributes(
                data: ["name": .string(name)]
            )
        )
    }

    private func getCurrentUserId() async throws -> UUID {
        let session = try await client.auth.session
        return session.user.id
    }

    private func fetchProfile(userId: UUID) async throws -> Profile {

        var profile: Profile?
        var retries = 0

        while profile == nil && retries < 10 {

            let response = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .execute()

            profile = try JSONDecoder()
                .decode([Profile].self, from: response.data)
                .first

            if profile == nil {
                try await Task.sleep(nanoseconds: 500_000_000)
                retries += 1
            }
        }

        guard let profile else {
            throw AuthError.profileNotFound
        }

        return profile
    }
}
