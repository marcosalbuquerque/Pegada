//
//  ContentView.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 16/12/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = true
    
    // Definição dos dados do Onboarding
    let onboardingData: [OnboardingItem] = [
        OnboardingItem(
            title: "Bem-vindo ao Pegada",
            description: "Acompanhe seus passos e descubra novos caminhos todos os dias.",
            icon: "map.fill"
        ),
        OnboardingItem(
            title: "Histórico Detalhado",
            description: "Visualize seu progresso com gráficos intuitivos e detalhados.",
            icon: "chart.bar.fill"
        ),
        OnboardingItem(
            title: "Privacidade Total",
            description: "Seus dados de localização ficam apenas no seu dispositivo.",
            icon: "lock.shield.fill"
        )
    ]

    var body: some View {
        if !hasSeenOnboarding {
            // Chama o componente passando os dados e o binding
            OnboardingView(items: onboardingData, isCompleted: $hasSeenOnboarding)
                .transition(.opacity)
        } else {
            if appState.isAuthenticated,
           let userId = appState.currentUserId {

            TabView {

                   MapView()
                    .tabItem {
                        Label("Mapa", systemImage: "map")
                    }

                ShopView(currentUserId: userId)
                    .tabItem {
                        Label("Loja", systemImage: "bag")
                    }
                Ranking(currentUserId: userId)
                    .tabItem {
                        Label("Ranking", systemImage: "trophy")
                    }
                User(currentUserId: userId.uuidString)
                    .tabItem {
                        Label("Perfil", systemImage: "person.fill")
                    }
                
            }

//                SharingView()
            } else {
                Login()
            }
        }
    }
}

#Preview {
    ContentView()
}
