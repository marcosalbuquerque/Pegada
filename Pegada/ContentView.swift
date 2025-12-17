//
//  ContentView.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 16/12/25.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
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
                
                // 3. RANKING
                Text("Ranking de Usuários")
                    .tabItem {
                        Label("Ranking", systemImage: "trophy.fill")
                    }
                
                // 4. PERFIL
                Text("Perfil do Usuário")
                    .tabItem {
                        Label("Perfil", systemImage: "person.fill")
                    }
            }

        } else {
            Login()
        }
    }
}

#Preview {
    ContentView()
}
