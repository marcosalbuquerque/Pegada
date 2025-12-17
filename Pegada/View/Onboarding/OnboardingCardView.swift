//
//  OnboardingItem.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 17/12/25.
//

import SwiftUI

struct OnboardingCardView: View {
    let item: OnboardingItem
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: item.icon)
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .foregroundColor(.blue) // Ou use a cor do seu app
                .padding(.bottom, 20)
            
            Text(item.title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Spacer()
        }
    }
}
