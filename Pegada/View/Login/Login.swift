import SwiftUI
import AuthenticationServices
import Supabase

// MARK: - Model

struct Profile: Decodable, Identifiable {
    let id: UUID
    let name: String?
    let email: String?
    let isActive: Bool
    let totalPoints: Int64
    let currentPoints: Int64
    let totalSafeCarbon: Double
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case isActive
        case totalPoints
        case currentPoints
        case totalSafeCarbon
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


// MARK: - View

struct Login: View {

    private let client = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )

    @State private var profile: Profile?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {

            if isLoading {
                ProgressView()
            }

            if let profile {
                Text("Bem-vindo, \(profile.name ?? "Usuário")")
                Text("Pontos: \(profile.currentPoints)")
            }

            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                handleAppleLogin(result: result)
            }
            .fixedSize()
        }
        .padding()
    }

    // MARK: - Apple Login Flow

    private func handleAppleLogin(result: Result<ASAuthorization, Error>) {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                // 1️⃣ Credencial Apple
                guard
                    let credential = try result.get().credential as? ASAuthorizationAppleIDCredential,
                    let tokenData = credential.identityToken,
                    let idToken = String(data: tokenData, encoding: .utf8)
                else {
                    throw NSError(domain: "AppleAuth", code: 0)
                }

                print("🍏 Apple Credential received:")
                print("User ID: \(credential.user)")
                print("Email: \(credential.email ?? "N/A")")
                print("Full Name: \(credential.fullName?.givenName ?? "N/A") \(credential.fullName?.familyName ?? "")")
                print("ID Token: \(idToken)")

                // 2️⃣ Login no Supabase
                let signInResponse = try await client.auth.signInWithIdToken(
                    credentials: OpenIDConnectCredentials(
                        provider: .apple,
                        idToken: idToken
                    )
                )
                print("🟢 Supabase sign-in response:", signInResponse)

                // 3️⃣ Atualiza nome no metadata (somente 1ª vez)
                if let fullName = credential.fullName {
                    let name = [
                        fullName.givenName,
                        fullName.middleName,
                        fullName.familyName
                    ]
                    .compactMap { $0 }
                    .joined(separator: " ")

                    let updateResponse = try await client.auth.update(
                        user: UserAttributes(
                            data: ["name": .string(name)]
                        )
                    )
                    print("✏️ Updated user metadata:", updateResponse)
                }

                // 4️⃣ Aguarda trigger criar o profile
                print("⏳ Aguardando trigger criar profile...")
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5s

                // 5️⃣ Busca profile criado pelo trigger
                let session = try await client.auth.session
                let userId = session.user.id
                print("🔑 Supabase session user ID:", userId)

                let response = try await client
                    .from("profiles")
                    .select()
                    .eq("id", value: userId)
                    .execute()

                print("📦 Raw profile response data:", String(data: response.data, encoding: .utf8) ?? "N/A")

                // 6️⃣ Decodifica o JSON em array
                let profiles = try JSONDecoder().decode([Profile].self, from: response.data)

                guard let profile = profiles.first else {
                    throw NSError(domain: "ProfileError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Profile não encontrado"])
                }

                self.profile = profile

                print("✅ Login completo")
                print("USER ID:", profile.id)
                print("Name:", profile.name ?? "N/A")
                print("Email:", profile.email ?? "N/A")
                print("Current Points:", profile.currentPoints)
                print("Total Points:", profile.totalPoints)
                print("Total Safe Carbon:", profile.totalSafeCarbon)
                print("Is Active:", profile.isActive)

            } catch {
                errorMessage = error.localizedDescription
                print("❌ Erro:", error.localizedDescription)
            }

            isLoading = false
        }
    }
}
