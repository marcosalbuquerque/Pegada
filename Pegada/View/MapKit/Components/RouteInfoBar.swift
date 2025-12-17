//
//  RouteInfoBar.swift
//  Pegada
//
//  Created by Daniel Leal PImenta on 16/12/25.
//

import MapKit
import SwiftUI

struct RouteInfoBar: View {
    let route: MKRoute
    let mode: TransportMode
    let onCancel: () -> Void
    let onStartNavigation: () -> Void
    let result: TripResult

    var body: some View {
        VStack(spacing: 20) {
            // 1. Cabeçalho: Ícone, Tempo/Distância e Fechar
            HStack(alignment: .center, spacing: 15) {
                // Ícone do Personagem ou Modo
                ZStack {
                    Circle()
                        .fill(Color("GreenHighlight").opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: mode.icon)
                        .font(.title2)
                        .foregroundStyle(Color("GreenHighlight"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Label(timeText, systemImage: "clock")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Label(distanceText, systemImage: "map")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.gray.opacity(0.5))
                }
            }
            
            // 2. Cartões de Impacto (CO2 e Pontos)
            HStack(spacing: 12) {
                ImpactCapsule(
                    text: "\(Int(result.carbonSavedGrams)) G CO2",
                    icon: "leaf.fill",
                    color: Color("DarkGreenGradient")
                )
                
                ImpactCapsule(
                    text: "\(result.pointsEarned) Pontos",
                    icon: "star.fill",
                    color: Color("DarkGreenGradient")
                )
            }
            
            // 3. Botão Iniciar
            Button(action: onStartNavigation) {
                Text("Iniciar")
                    .font(.title3.bold())
                    .foregroundStyle(Color("DarkGreenGradient"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color("GreenHighlight"))
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(.ultraThinMaterial) // Efeito transparente desfocado
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding()
    }

    // Helpers de Formatação
    private var timeText: String {
        let minutes = Int((route.expectedTravelTime * mode.timeMultiplier) / 60)
        return minutes < 60 ? "\(minutes) min" : "\(minutes / 60)h \(minutes % 60) min"
    }

    private var distanceText: String {
        route.distance < 1000 ? "\(Int(route.distance)) m" : String(format: "%.1f km", route.distance / 1000)
    }
}

// Componente auxiliar para as cápsulas de CO2 e Pontos
struct ImpactCapsule: View {
    let text: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color("GreenHighlight"))
            Text(text)
                .font(.headline)
                .foregroundStyle(Color("GreenHighlight"))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(color.opacity(0.8))
        .clipShape(Capsule())
    }
}
