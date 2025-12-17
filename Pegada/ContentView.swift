import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = true

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
        ),
    ]

    var body: some View {
        if !hasSeenOnboarding {

            OnboardingView(
                items: onboardingData,
                isCompleted: $hasSeenOnboarding
            )

        } else {

            if appState.isAuthenticated,
               let userId = appState.currentUserId {

                let userService = UserService(
                    baseURL: "https://pegada-backend-production.up.railway.app/api"
                )

                TabView {
                    MapView()
                        .tabItem { Label("Mapa", systemImage: "map") }

                    ShopView(
                        currentUserId: userId,
                        modelContext: modelContext,
                        userService: userService
                    )
                    .tabItem { Label("Cupons", systemImage: "ticket") }

                    Ranking(currentUserId: userId)
                        .tabItem { Label("Ranking", systemImage: "trophy") }

                    User(
                        currentUserId: userId,
                        modelContext: modelContext,
                        userService: userService
                    )
                    .tabItem { Label("Perfil", systemImage: "person.fill") }
                }

            } else {
                Login(
                    viewModel: LoginViewModel(
                        modelContext: modelContext
                    )
                )
            }
        }
    }
}
