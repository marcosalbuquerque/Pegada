import SwiftUI
import AuthenticationServices

struct Login: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var vm: LoginViewModel

    init(viewModel: LoginViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 16) {

            if vm.isLoading {
                ProgressView()
            }

            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                Task {
                    await handleLogin(result: result)
                }
            }
            .fixedSize()
        }
        .padding()
    }

    private func handleLogin(
        result: Result<ASAuthorization, Error>
    ) async {

        vm.isLoading = true
        vm.errorMessage = nil

        do {
            let profile = try await vm.loginWithApple(result: result)

            appState.isAuthenticated = true
            appState.currentUserId = profile.id

        } catch {
            vm.errorMessage = error.localizedDescription
        }

        vm.isLoading = false
    }
}
