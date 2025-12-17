//
//  OnboardingItem.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 17/12/25.
//

import SwiftUI

struct OnboardingItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String // Pode ser nome de SF Symbol ou Asset
}
