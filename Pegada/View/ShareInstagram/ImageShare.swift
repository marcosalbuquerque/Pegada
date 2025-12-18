//
//  ImageShare.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 18/12/25.
//

import SwiftUI
import MapKit

struct ImageShare: View {
    
    // Recebe a imagem já gerada com a rota desenhada
    let mapImage: UIImage?
    
    let carbonSaved: Double
    let pointsEarned: Int
    
    var body: some View {
        ZStack {
            // 1. Fundo Dark
            Color.headerDark.ignoresSafeArea()

            // 2. Elementos de Fundo (Blur Sutil)
            VStack {
                Circle()
                    .fill(Color.greenHighlight.opacity(0.1))
                    .frame(width: 500, height: 500)
                    .blur(radius: 80)
                    .offset(x: -150, y: -300)
                Spacer()
            }
            
            VStack(spacing: 25) {
                
                // --- CABEÇALHO ---
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.title3)
                        .foregroundStyle(Color.greenHighlight)
                    Text("PEGADA")
                        .font(.headline)
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.top, 60)
                
                Spacer()
                
                // --- O MAPA (Hero) ---
                ZStack {
                    RoundedRectangle(cornerRadius: 36)
                        .fill(Color.black.opacity(0.2))
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        .shadow(color: .black.opacity(0.6), radius: 30, y: 15)
                    
                    if let image = mapImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 320, height: 320)
                            .clipShape(RoundedRectangle(cornerRadius: 36))
                            .overlay(
                                RoundedRectangle(cornerRadius: 36)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    } else {
                        // Fallback elegante
                        VStack(spacing: 16) {
                            Image(systemName: "map.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(Color.greenHighlight.opacity(0.3))
                        }
                        .frame(width: 320, height: 320)
                    }
                }
                .frame(width: 320, height: 320)
                
                // --- FRASE DE IMPACTO ---
                Text("Menos carbono, mais futuro.")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.top, 10)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                // --- CARDS DE ESTATÍSTICAS ---
                HStack(spacing: 16) {
                    
                    // Card 1: Carbono
                    StatsCard(
                        icon: "leaf.fill",
                        iconColor: .greenHighlight,
                        value: "\(Int(carbonSaved))g",
                        label: "CO2 Poupado"
                    )
                    
                    // Card 2: Pontos
                    StatsCard(
                        icon: "star.fill",
                        iconColor: .yellow,
                        value: "+\(pointsEarned)",
                        label: "Pontos"
                    )
                }
                .padding(.top, 10)
                Spacer()
            }
        }
        .frame(width: 414, height: 736) // Proporção Story
    }
}

// Subcomponente de Card (Para garantir design igual)
struct StatsCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(width: 150, height: 130)
        .background(Color.white.opacity(0.05))
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(iconColor.opacity(0.3), lineWidth: 1.5)
        )
    }
}
