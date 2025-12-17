//
//  AppState.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class AppState: ObservableObject {

    @Published var isAuthenticated = false
    @Published var currentUserId: UUID?

    func restoreSession(profileStore: ProfileStore) {
        if let profile = try? profileStore.fetchCurrentProfile() {
            isAuthenticated = true
            currentUserId = profile.id
        } else {
            isAuthenticated = false
            currentUserId = nil
        }
    }

    func logout(profileStore: ProfileStore) {
        try? profileStore.deleteAll()
        isAuthenticated = false
        currentUserId = nil
    }
}


