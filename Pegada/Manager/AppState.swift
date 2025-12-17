//
//  AppState.swift
//  Pegada
//
//  Created by João Felipe Schwaab on 16/12/25.
//


import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {

    @Published var isAuthenticated: Bool = false
    @Published var profile: Profile?
}
