//
//  PegadaApp.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 16/12/25.
//

import SwiftUI
import SwiftData

@main
struct PegadaApp: App {

    let container: ModelContainer
    @StateObject private var appState = AppState()

    init() {
        container = try! ModelContainer(for: ProfileEntity.self)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .modelContainer(container)
                .onAppear {
                    let store = ProfileStore(context: container.mainContext)
                    appState.restoreSession(profileStore: store)
                }
                .preferredColorScheme(.dark)
        }
    }
}

