//
//  ImpactCard.swift
//  Pegada
//
//  Created by Gustavo Souto Pereira on 17/12/25.
//

import SwiftUI

struct ImpactCard: View {
    let co2: String
    let trees: Int
    let mode: TransportMode
    let points: Int
    
    var body: some View {
        VStack(spacing: 15) {
            // Linha superior: CO2 e Árvores
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Color("GreenHighlight"))
                Text("\(co2) CO2")
                Spacer()
                Text("=")
                    .foregroundStyle(Color("GreenHighlight"))
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "tree.fill")
                    .foregroundStyle(Color("GreenHighlight"))
                Text("+ \(trees) árvores")
            }
            .frame(maxWidth: .infinity)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal)
            
            Divider()
                .background(Color("GreenHighlight"))
            
            // Linha inferior: Modalidade e Pontos
            HStack {
                Label {
                    Text(mode.rawValue)
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: mode.icon)
                        .foregroundStyle(Color("GreenHighlight"))
                }
                .fontWeight(.semibold)
                
                Spacer()
                
                // Label para Pontos
                Label {
                    Text("\(points) Pontos")
                        .foregroundStyle(.white)
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color("GreenHighlight"))
                }
                .fontWeight(.semibold)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
