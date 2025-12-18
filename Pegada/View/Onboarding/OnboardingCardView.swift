//
//  OnboardingCardView.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 17/12/25.
//

import SwiftUI

struct OnboardingCardView: View {
    let item: OnboardingItem
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Círculo de fundo sutil para dar destaque ao ícone
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                
                Image(systemName: item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(Color.greenHighlight) // Use sua cor customizada aqui
            }
            .padding(.bottom, 30)
            
            VStack(spacing: 16) {
                Text(item.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(item.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary) // Cinza claro padrão do modo dark
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding()
    }
}
