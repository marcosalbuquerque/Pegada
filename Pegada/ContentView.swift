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
        if appState.isAuthenticated {
            MapView()
        } else {
            Login()
        }
    }
}


#Preview {
    ContentView()
}
