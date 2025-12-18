import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    let onboardingData: [OnboardingItem] = [
        OnboardingItem(
            title: "O Mundo em Equilíbrio",
            description: "Cada viagem conta. Descubra como seus trajetos impactam o planeta e assuma o controle da sua pegada de carbono.",
            icon: "globe.americas.fill"
        ),
        OnboardingItem(
            title: "Rastreamento Inteligente",
            description: "Acompanhe suas rotas em tempo real e visualize sua economia de CO2. Tecnologia a favor da consciência ambiental.",
            icon: "location.fill.viewfinder"
        ),
        OnboardingItem(
            title: "Sustentabilidade Recompensada",
            description: "Transforme escolhas verdes em benefícios reais. Acumule pontos, resgate cupons exclusivos e deixe seu legado.",
            icon: "leaf.fill"
        )
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
                .tint(Color.greenHighlight)
                .onAppear {
                                    userService.fetchUserProfile(userId: userId.uuidString) { result in
                                        switch result {
                                            case .success(let remoteProfile):
                                            Task { @MainActor in
                                                let profileStore = ProfileStore(context: modelContext)
                                                profileStore.sincWithApi(profile: remoteProfile)
                                            }

                                        case .failure(let error):
                                            print("ERRO AO BUSCAR PERFIL REMOTO:", error)
                                        }
                                    }
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
