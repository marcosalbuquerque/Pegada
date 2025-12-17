//
//  ActionButton.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 17/12/25.
//

import SwiftUI

struct ActionButton: View {
    let title: String
        let systemImage: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.title3)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                // Usando a cor de destaque do seu app
                .background(Color("GreenHighlight"))
                // Cor do texto e ícone (Verde escuro para contraste)
                .foregroundStyle(Color("DarkGreenGradient"))
                .clipShape(Capsule())
            }
        }
}
