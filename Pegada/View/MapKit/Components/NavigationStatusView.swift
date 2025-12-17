//
//  NavigationStatusView.swift
//  Pegada
//
//  Created by Marcos Albuquerque on 16/12/25.
//


import SwiftUI
import MapKit

struct NavigationStatusView: View {
    
    let destinationName: String
    let route: MKRoute
    let tripResult: TripResult
    
    // Valores calculados em tempo real vindos da MapView
    let currentProgress: (points: Int, co2: Double, progress: Double)
    let formatDistance: (CLLocationDistance) -> String
    let onStop: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. Cabeçalho (Destino e Botão Parar)
            HStack(alignment: .center, spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color("GreenHighlight").opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(tripResult.mode.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Em viagem para")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(destinationName)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: onStop) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red.opacity(0.8))
                }
            }
            
            // 2. Barra de Progresso Visual
            VStack(spacing: 10) {
                HStack {
                    Text(formatDistance(route.distance * currentProgress.progress))
                        .font(.caption.bold())
                        .foregroundStyle(.blue)
                    Spacer()
                    Text("Faltam \(formatDistance(route.distance * (1 - currentProgress.progress)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .frame(height: 8)
                            .foregroundStyle(.white.opacity(0.1))
                        
                        Capsule()
                            .frame(width: geo.size.width * currentProgress.progress, height: 8)
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .mint], startPoint: .leading, endPoint: .trailing)
                            )
                            .animation(.spring(), value: currentProgress.progress)
                    }
                }
                .frame(height: 8)
            }
            
            // 3. Métricas de Impacto em Tempo Real (Cápsulas Estilizadas)
            HStack(spacing: 12) {
                // Cápsula de CO2
                ImpactCapsule(
                    text: "\(Int(currentProgress.co2))g / \(Int(tripResult.carbonSavedGrams))g",
                    icon: "leaf.fill",
                    color: Color("DarkGreenGradient")
                )
                .contentTransition(.numericText(value: currentProgress.co2))
                
                // Cápsula de Pontos
                ImpactCapsule(
                    text: "\(currentProgress.points) / \(tripResult.pointsEarned) pts",
                    icon: "star.fill",
                    color: Color("DarkGreenGradient")
                )
                .contentTransition(.numericText(value: Double(currentProgress.points)))
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding()
        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
    }
}
