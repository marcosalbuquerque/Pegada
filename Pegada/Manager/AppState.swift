//
//  AppState.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class AppState: ObservableObject {

    @Published var isAuthenticated: Bool = false
    @Published var profile: Profile? // Assumindo que você tem uma struct Profile definida em outro lugar
    
    // Variável que controla se o usuário já viu o onboarding
    @Published var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }

    init() {
        // Ao iniciar, lê o valor salvo. Se não existir, retorna false por padrão.
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
    
    func completeOnboarding() {
        withAnimation {
            hasSeenOnboarding = true
        }
    }
    @Published var currentUserId: UUID?
}
