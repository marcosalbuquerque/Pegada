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
            }

        } else {
            Login()
        }
    }
}

#Preview {
    ContentView()
}
