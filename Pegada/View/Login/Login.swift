import SwiftUI
import AuthenticationServices

struct Login: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var vm: LoginViewModel

    init(viewModel: LoginViewModel) {
        _vm = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            // Fundo seguindo o padrão do MapView e User
            Color.headerDark
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Spacer no topo para empurrar o conteúdo para o centro
                Spacer()
                
                // --- CONTEÚDO CENTRALIZADO ---
                VStack(spacing: 40) {
                    
                    // Logo e Títulos
                    VStack(spacing: 16) {
                        Image("pe") // Imagem do Asset "pe"
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                        
                        Text("Pegada")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.allWhite)
                        
                        Text("Sua jornada sustentável começa aqui.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Feedback de Status (Loading ou Erro)
                    Group {
                        if vm.isLoading {
                            ProgressView()
                                .tint(.greenHighlight)
                        } else if let error = vm.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(height: 20) // Espaço reservado para não mover os botões
                    
                    // Botão Apple
                    SignInWithAppleButton { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        Task {
                            await handleLogin(result: result)
                        }
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .clipShape(Capsule())
                    .padding(.horizontal, 30)
                }
                
                // Spacer no fundo para equilibrar a centralização
                Spacer()
            }
        }
    }

    private func handleLogin(result: Result<ASAuthorization, Error>) async {
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
