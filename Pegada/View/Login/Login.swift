//
//  Login.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//

import SwiftUI
import AuthenticationServices

struct Login: View {

    @StateObject private var vm = LoginViewModel()

    var body: some View {
        VStack(spacing: 16) {

            if vm.isLoading {
                ProgressView()
            }

            if let profile = vm.profile {
                Text("Bem-vindo, \(profile.name ?? "Usuário")")
                Text("Pontos: \(profile.currentPoints)")
            }

            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            SignInWithAppleButton { request in
                request.requestedScopes = [.email, .fullName]
            } onCompletion: { result in
                vm.loginWithApple(result: result)
            }
            .fixedSize()
        }
        .padding()
    }
}
